//
//  ProfileViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 27.02.2025.
//

import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userAvatar: UIImage?
    @Published var coinCount: Int = 0
    @Published var nickname: String = ""
    @Published var isPhotoSourceActionSheetPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    @Published var isCameraPresented: Bool = false
    @Published var isFilePickerPresented: Bool = false
    @Published var isSignedIn: Bool = true
    @Published var isAvatarLoading: Bool = false
    @Published var isAvatarLoadingFailed = false
    @Published var isLoading = false
    @Published var errorPresented: Bool = false
    @Published var error: UserRepresentableError = GenericErrors.generic
    @Published var deleteAccountSuccess: Bool = false

    @Inject
    private var userSessionProvider: UserSessionProvider
    private var cancellables = Set<AnyCancellable>()

    init() {
        bindUserData()
    }

    private func bindUserData() {
        if let userNickname = userSessionProvider.user?.nickname {
            nickname = userNickname
        }
        userSessionProvider.userStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let userNickname = user?.nickname {
                    self?.nickname = userNickname
                }
            }
            .store(in: &cancellables)

        userSessionProvider.userCollectedCoinsAmountStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.coinCount = coins
            }
            .store(in: &cancellables)

        isAvatarLoading = true
        userSessionProvider.getUserPhoto()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isAvatarLoading = false
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.isAvatarLoadingFailed = true
                }
            }, receiveValue: { [weak self] data in
                if let image = UIImage(data: data) {
                    self?.userAvatar = image
                    self?.isAvatarLoadingFailed = false
                }
            })
            .store(in: &cancellables)
    }

    func handleImageSelection(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }

        isAvatarLoading = true
        isAvatarLoadingFailed = false
        userSessionProvider.update(photo: imageData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isAvatarLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.error = (error as? UserRepresentableError) ?? GenericErrors.generic
                    self?.errorPresented = true
                }
            }, receiveValue: { [weak self] success in
                if success {
                    self?.userAvatar = image
                }
            })
            .store(in: &cancellables)
    }

    func signOut() {
        userSessionProvider.signOutSession()
    }

    func deleteAccount() {
        #warning("add confirmation modal if user really wanna delete all data")
        isLoading = true
        userSessionProvider.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.error = (error as? UserRepresentableError) ?? GenericErrors.generic
                    self?.errorPresented = true
                }
            }, receiveValue: { [weak self] success in
                if success {
                    self?.deleteAccountSuccess = true
                }
            })
            .store(in: &cancellables)
    }
}
