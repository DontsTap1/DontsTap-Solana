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
    @Published var isLoading = false
    @Published var errorPresented: Bool = false
    @Published var errorText: String = ""
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
            }, receiveValue: { [weak self] data in
                if let image = UIImage(data: data) {
                    self?.userAvatar = image
                }
            })
            .store(in: &cancellables)
    }

    func handleImageSelection(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }

        isAvatarLoading = true
        userSessionProvider.update(photo: imageData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isAvatarLoading = false
                if case .failure(let error) = completion {
                    self?.errorText = error.localizedDescription
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
        isLoading = true
        userSessionProvider.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorText = error.localizedDescription
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
