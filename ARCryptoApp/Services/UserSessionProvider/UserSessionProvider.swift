import Combine
import Foundation
import UIKit
import FirebaseStorage

enum UserSessionError: Error, UserRepresentableError {
    case noExistingPhotoForUser
    case incorrectSignUp
    case failedToUploadPhoto
    case nicknameIsNotUnique

    var userErrorText: String {
        return String.genericErrorText
    }

    var userErrorDescription: String? {
        switch self {
        case .noExistingPhotoForUser:
            return String(localized: "You do not have a photo. Please try again.")
        case .incorrectSignUp:
            return String.genericErrorText
        case .failedToUploadPhoto:
            return String(localized: "Upload of photo failed, please try again.")
        case .nicknameIsNotUnique:
            return String(localized: "This nickname is already taken, please try another one.")
        }
    }
}

typealias UserInfo = (nickname: String?, photo: Data?)

protocol UserSessionProvider {
    var isGuestUser: Bool { get }
    var user: User? { get }
    var userCachedPhotoData: Data? { get }
    var userStream: AnyPublisher<User?, Never> { get }
    var userDidUploadPhotoStream: AnyPublisher<Bool, Never> { get }
    var userCollectedCoinsAmountStream: AnyPublisher<Int, Never> { get }
    var authToken: String? { get }

    func update(photo: Data) -> AnyPublisher<Bool, Error>

    func getCoins() -> AnyPublisher<[Coin], Never>
    func addCoin(_ coin: Coin)
    func addCoins(_ coins: [Coin])

    func getUserInfo() -> AnyPublisher<UserInfo, Never>
    func getUserInfo(ignoreCachedPhoto: Bool) -> AnyPublisher<UserInfo, Never>
    
    func getUserPhoto() -> AnyPublisher<Data?, any Error>
    func getUserPhoto(ignoreCachedPhoto: Bool) -> AnyPublisher<Data?, any Error>

    func addPromocode(_ promocode: Promocode) -> Bool

    func signUpSession(nickname: String, photo: Data?) -> AnyPublisher<Bool, Error>
    func signInSession(authToken: String, email: String?) -> AnyPublisher<AuthenticationStatus, Error>
    func signOutSession()
    func deleteAccount() -> AnyPublisher<Bool, Error>
}

class UserSessionService: UserSessionProvider {
    private let databaseProvider: DatabaseProvider
    private let keychainStore: KeychainStoreProvider

    private var userStreamCancellable: AnyCancellable?
    private var userFetchCancellable: AnyCancellable?
    private var uniqueNicknameCancellable: AnyCancellable?
    private var userPhotoUploadCancellable: AnyCancellable?
    private var userPhotoDownloadCancellable: AnyCancellable?

    init(
        keychainStore: KeychainStoreProvider,
        databaseProvider: DatabaseProvider
    ) {
        self.keychainStore = keychainStore
        self.databaseProvider = databaseProvider

        loadUserInitialState()
    }
    
    private var compressPhotoCancellable: AnyCancellable?
    private var uploadPhotoCancellable: AnyCancellable?
    private var deleteUserPhotoCancellable: AnyCancellable?

    private(set) var userCachedPhotoData: Data?
    private(set) var user: User?
    var userStream: AnyPublisher<User?, Never> {
        guard let userId = user?.id ?? UIDevice.current.identifierForVendor?.uuidString else {
            return Just<User?>(nil)
                .eraseToAnyPublisher()
        }

        return databaseProvider.observeUser(userId: userId)
    }
    var userDidUploadPhotoStream: AnyPublisher<Bool, Never> {
        return _userDidUploadPhotoStream
            .eraseToAnyPublisher()
    }

    var userCollectedCoinsAmountStream: AnyPublisher<Int, Never> {
        return _userCollectedCoinsAmountStream
            .eraseToAnyPublisher()
    }

    private var _userStream: PassthroughSubject<User?, Never> {
        return databaseProvider.userStream
    }

    private let _userDidUploadPhotoStream = PassthroughSubject<Bool, Never>()
    private let _userCollectedCoinsAmountStream = CurrentValueSubject<Int, Never>(0)

    var isGuestUser: Bool {
        !(authToken != nil && (user?.status ?? .guest) != .guest)
    }

    var authToken: String? {
        keychainStore.get(for: .userToken)
    }

    func signUpSession(nickname: String, photo: Data?) -> AnyPublisher<Bool, Error> {
        guard let authToken = authToken else {
            return Fail(error: UserSessionError.incorrectSignUp)
                .eraseToAnyPublisher()
        }
        print("sign up started")

        return Future<Bool, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(GenericErrors.generic))
                return
            }

            uniqueNicknameCancellable = databaseProvider.checkIfNicknameUnique(nickname: nickname)
                .sink { isUnique in
                    if isUnique {
                        print("sign up nickname unique")
                        if let photo {
                            print("sign up photo upload started")
                            self.userPhotoUploadCancellable = self.update(photo: photo)
                                .sink { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        print("sign up photo upload failed")
                                        promise(.failure(error))
                                    }
                                } receiveValue: { isPhotoUploaded in
                                    if isPhotoUploaded {
                                        print("sign up finished")
                                        self.update(authToken: authToken, status: .signedIn, email: self.user?.email, nickname: nickname)
                                        promise(.success(true))
                                    }
                                    else {
                                        print("sign up failed")
                                        promise(.failure(UserSessionError.failedToUploadPhoto))
                                    }
                                }
                            return
                        }
                        else {
                            print("sign up finished without photo upload")
                            self.update(authToken: authToken, status: .signedIn, email: self.user?.email, nickname: nickname)
                            promise(.success(true))
                            return
                        }
                    }
                    print("sign up failed nickname not unique")
                    promise(.failure(UserSessionError.nicknameIsNotUnique))
                }
        }
        .eraseToAnyPublisher()
    }

    func signInSession(authToken: String, email: String?) -> AnyPublisher<AuthenticationStatus, Error> {
        keychainStore.store(authToken, for: .userToken)
        update(authToken: authToken)
        if let email {
            update(email: email)
        }

        #warning("check if auth token gives more information")
        return databaseProvider.getUser(userId: UIDevice.current.identifierForVendor!.uuidString)
            .map { remoteUser in
                if let remoteUser, remoteUser.nickname != nil {
                    self.update(status: .signedIn)
                    return .signedIn
                }
                return .redirectToSignUp
            }
            .eraseToAnyPublisher()
    }

    func signOutSession() {
        update(status: .guest)
        keychainStore.delete(for: .userToken)
        userCachedPhotoData = nil
    }
    
    func deleteAccount() -> AnyPublisher<Bool, Error> {
        guard let user else {
            return Fail<Bool, any Error>(error: UserSessionError.noExistingPhotoForUser)
                .eraseToAnyPublisher()
        }

        return Future<Bool, Error> { [weak self] result in
            guard let self else {
                return
            }
            let photoId = user.photoId ?? user.id
            deleteUserPhotoCancellable = Publishers.CombineLatest(databaseProvider.deletePhoto(photoId: photoId), databaseProvider.delete(userId: user.id))
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        let nsError = error as NSError
                        // Error that indicates that user just doesn't have photo , that's why it wasn't deleted
                        if let underlyingNSError = nsError.underlyingErrors.first as? NSError,
                           underlyingNSError.code == 404 {
                            self?.deleteUserAccountCachedData()
                            result(.success(true))
                        }
                        else {
                            result(.failure(error))
                        }
                    }
                } receiveValue: { [weak self] isPhotoDeleted, isUserDeleted in
                    if isPhotoDeleted, isUserDeleted {
                        self?.deleteUserAccountCachedData()
                    }
                    result(.success(isPhotoDeleted && isUserDeleted))
                }
        }
        .eraseToAnyPublisher()
    }

    private func deleteUserAccountCachedData() {
        guard (user?.id) != nil else {
            return
        }

        keychainStore.delete(for: .userToken)
        keychainStore.delete(for: .user)

        let deviceId = UIDevice.current.identifierForVendor!
        let emptyUser = User(id: deviceId.uuidString)
        user = emptyUser
        update(status: .guest)

        _userStream.send(user)

        userCachedPhotoData = nil
    }

    private func loadUserInitialState() {
        if let storedUser: User = keychainStore.get(for: .user),
           let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            // in case stored user id (deviceId) differs from current one.
            // this could happen if for example user deleted the app, but keychain still store the data
            // and now app installed one more time, but device id changed
            var newStoredUser = storedUser
            if storedUser.id != deviceId {
                newStoredUser = storedUser.update(id: deviceId)
                // this needed due to migration from old version to new version of app
                // in some cases users has photos from old versions stored with old id
                // while in new app version they can get new id, cause of deviceId change
                // to avoid missing of photo , we making such tmp solution
                // when user gonna upload new photo in new version we gonna assign the correct id
                if storedUser.photoId == nil {
                    newStoredUser = newStoredUser.update(photoId: storedUser.id)
                }
            }
            update(user: newStoredUser)
        }
        else {
            let deviceId = UIDevice.current.identifierForVendor!
            userFetchCancellable = databaseProvider.getUser(userId: deviceId.uuidString)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        // if this call fails it means that user has never created on this device account
                        // and remote data is not available, so we can just make him as fresh local user. after sign in the data should update
                        let newFreshLocalUser = User(id: deviceId.uuidString)
                        self?.update(user: newFreshLocalUser)
                    }
                }, receiveValue: { [weak self] remoteUser in
                    guard let self else {
                        return
                    }

                    if let remoteUser {
                        update(user: remoteUser)
                    }
                    else {
                        let newFreshUser = User(id: deviceId.uuidString)
                        update(user: newFreshUser)
                    }
                })
        }
    }
}

extension UserSessionService {
    func update(email: String) {
        guard let user else {
            return
        }

        let newUser = User(
            id: user.id,
            email: email,
            nickname: user.nickname,
            coins: user.coins,
            promocodes: user.promocodes,
            status: user.status,
            authToken: user.authToken
        )

        update(user: newUser)
    }

    func update(photo: Data) -> AnyPublisher<Bool, Error> {
        guard let user else {
            return Fail(error: UserSessionError.failedToUploadPhoto)
                .eraseToAnyPublisher()
        }

        return Future<Bool, Error> { [weak self] result in
            let compressedPhoto = UIImage(data: photo)?.jpegData(compressionQuality: 0.5)
            let photoToUpload = compressedPhoto ?? photo
            let photoId: String
            if user.photoId == nil || (user.photoId != user.id) {
                photoId = user.id
            }
            else {
                photoId = user.photoId ?? user.id
            }
            self?.uploadPhotoCancellable = self?.databaseProvider.store(photoData: photoToUpload, with: photoId)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        result(.failure(failure))
                    }
                }, receiveValue: { [weak self] success in
                    if user.photoId == nil || user.photoId != user.id {
                        self?.update(photoId: user.id)
                    }
                    self?.userCachedPhotoData = photoToUpload
                    result(.success(success))
                    self?._userDidUploadPhotoStream.send(true)
                })
        }
        .eraseToAnyPublisher()
    }

    private func deleteUserPhoto() -> AnyPublisher<Bool, Error> {
        guard let photoId = user?.photoId ?? user?.id else {
            return Fail(error: UserSessionError.noExistingPhotoForUser)
                .eraseToAnyPublisher()
        }

        userCachedPhotoData = nil
        return databaseProvider.deletePhoto(photoId: photoId)
    }

    func getCoins() -> AnyPublisher<[Coin], Never> {
        guard let userId = user?.id else {
            return Just([Coin]())
                .eraseToAnyPublisher()
        }
        return databaseProvider.getCoins(userId: userId)
    }

    func addCoin(_ coin: Coin) {
        guard let user else {
            return
        }

        let newUser = user.appendCoin(coin)
        update(user: newUser)
    }

    func addCoins(_ coins: [Coin]) {
        guard let user else {
            return
        }

        let newUser = user.appendCoins(coins)
        update(user: newUser)
    }

    func getUserInfo() -> AnyPublisher<UserInfo, Never> {
        return getUserInfo(ignoreCachedPhoto: false)
    }

    func getUserInfo(ignoreCachedPhoto: Bool) -> AnyPublisher<UserInfo, Never> {
        guard !isGuestUser else {
            return Just<UserInfo>((nil, nil))
                .eraseToAnyPublisher()
        }

        return getUserPhoto(ignoreCachedPhoto: ignoreCachedPhoto)
            .map { [weak self] photoData in
                return (self?.user?.nickname, photoData)
            }
            .replaceError(with: (user?.nickname, nil))
            .eraseToAnyPublisher()
    }

    func getUserPhoto() -> AnyPublisher<Data?, any Error> {
        getUserPhoto(ignoreCachedPhoto: false)
    }

    func getUserPhoto(ignoreCachedPhoto: Bool) -> AnyPublisher<Data?, any Error> {
        if !ignoreCachedPhoto, let userCachedPhotoData {
            return Future<Data?, Error> { promise in
                promise(.success(userCachedPhotoData))
            }
            .eraseToAnyPublisher()
        }

        guard let photoId = user?.photoId ?? user?.id, authToken != nil else {
            return Fail(error: UserSessionError.noExistingPhotoForUser)
                .eraseToAnyPublisher()
        }

        return databaseProvider.getPhoto(photoId: photoId)
            .map { Optional($0) }
            .catch { error -> AnyPublisher<Data?, Error> in
                if let storageError = error as? StorageError, storageError.isNotFoundError {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] photoData in
                self?.userCachedPhotoData = photoData
            })
            .eraseToAnyPublisher()
    }

    func addPromocode(_ promocode: Promocode) -> Bool {
        guard let user else {
            return false
        }

        guard !user.promocodes.contains(where: { $0.id == promocode.id }) else {
            return false
        }

        let newUser = user.appendPromocode(promocode)
        update(user: newUser)

        return true
    }
}

// MARK: - Helper methods
extension UserSessionService {
    private func update(user: User, withDatabaseUpdate: Bool = true) {
        self.user = user
        keychainStore.store(user, for: .user)
        if let authToken = user.authToken {
            keychainStore.store(authToken, for: .userToken)
        }
        if withDatabaseUpdate {
            try? databaseProvider.storeUser(user: user)
        }

        if _userCollectedCoinsAmountStream.value != user.coins.count {
            _userCollectedCoinsAmountStream.send(user.coins.count)
        }
    }

    private func update(authToken: String, status: User.Status, email: String?, nickname: String?) {
        guard let user else {
            return
        }

        update(user: user.update(authToken: authToken, status: status, email: email, nickname: nickname))
    }

    private func update(authToken: String, status: User.Status) {
        guard let user else {
            return
        }

        update(user: user.update(authToken: authToken, status: status))
    }

    private func update(authToken: String, status: User.Status, nickname: String) {
        guard let user else {
            return
        }

        update(user: user.update(authToken: authToken, status: status, nickname: nickname))
    }

    private func update(authToken: String?) {
        guard let user else {
            return
        }

        update(user: user.update(authToken: authToken))
    }

    private func update(status: User.Status) {
        guard let user else {
            return
        }

        update(user: user.update(status: status))
    }

    private func update(nickname: String) {
        guard let user else {
            return
        }

        update(user: user.update(nickname: nickname))
    }

    private func update(photoId: String) {
        guard let user else {
            return
        }

        update(user: user.update(photoId: photoId))
    }
}

fileprivate extension User {
    func update(id: String) -> User {
        return User(
            id: id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    func update(authToken: String, status: User.Status, email: String?, nickname: String?) -> User {
        return User(
            id: self.id,
            email: email,
            nickname: nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: status,
            authToken: authToken,
            photoId: self.photoId
        )
    }

    func update(authToken: String, status: User.Status) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: status,
            authToken: authToken,
            photoId: self.photoId
        )
    }

    func update(authToken: String, status: User.Status, nickname: String) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: status,
            authToken: authToken,
            photoId: self.photoId
        )
    }

    func update(authToken: String?) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: self.status,
            authToken: authToken,
            photoId: self.photoId
        )
    }

    func update(status: User.Status) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    func update(nickname: String) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    func update(photoId: String) -> User {
        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: self.promocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: photoId
        )
    }

    func appendCoin(_ coin: Coin) -> User {
        var coinList = self.coins
        coinList.append(coin)
        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: coinList,
            promocodes: self.promocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    func appendCoins(_ coins: [Coin]) -> User {
        var coinList = self.coins
        coinList.append(contentsOf: coins)

        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: coinList,
            promocodes: self.promocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    func appendPromocode(_ promocode: Promocode) -> User {
        var newPromocodes = self.promocodes
        newPromocodes.append(promocode)

        return User(
            id: self.id,
            email: self.email,
            nickname: self.nickname,
            coins: self.coins,
            promocodes: newPromocodes,
            status: self.status,
            authToken: self.authToken,
            photoId: self.photoId
        )
    }

    static func createEmptyUser(id: String) -> User {
        return User(id: id)
    }
}

private extension StorageError {
    var isNotFoundError: Bool {
        if case .objectNotFound = self,
           let serverError = serverError,
           let errorCode = serverError.first(where: { $0.key == "ResponseErrorCode" })?.value as? Int,
           errorCode == 404 {
            return true
        }
        return false
    }
    
    private var serverError: [String: Any]? {
        switch self {
        case .objectNotFound(_, let serverError),
             .unknown(_, let serverError),
             .quotaExceeded(_, let serverError),
             .unauthenticated(let serverError),
             .unauthorized(_, _, let serverError):
            return serverError
        default:
            return nil
        }
    }
}
