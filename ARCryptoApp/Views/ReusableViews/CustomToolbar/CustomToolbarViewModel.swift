//
//  CustomToolbarViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 02.03.2025.
//

import Combine
import SwiftUI

class TopToolbarViewModel: ObservableObject {
    @Published var avatar: UIImage?
    @Published var nickname: String?
    @Published var coinCount: Int = 0
    @Published var shouldRenderUserData = false
    @Published var isLoadingUserData = false
    private var avatarData: Data? {
        didSet {
            if let avatarData {
                avatar = UIImage(data: avatarData)
            }
        }
    }

    @Inject
    private var userSessionProvider: UserSessionProvider
    @Inject
    var coinCollectProvider: CoinCollectStoreProvider

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchUserData()
    }

    private func fetchUserData() {
        // User stream to observe change of user status
        userSessionProvider.userStream
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] user in
                if let nickname = user?.nickname {
                    self?.nickname = nickname
                }
                if let userStatus = user?.status {
                    self?.shouldRenderUserData = userStatus != .guest
                }
            })
            .store(in: &cancellables)

        // User info
        isLoadingUserData = true
        userSessionProvider.getUserInfo()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoadingUserData = false
            }, receiveValue: { [weak self] userInfo in
                if let nickname = userInfo.nickname {
                    self?.nickname = nickname
                }
                if let avatarImageData = userInfo.photo {
                    self?.avatarData = avatarImageData
                }
            })
            .store(in: &cancellables)

        // User photo upload stream to observe updates
        userSessionProvider.userDidUploadPhotoStream
            .receive(on: DispatchQueue.main)
            .sink { completion in
                return
            } receiveValue: { [weak self] newPhotoUploaded in
                if newPhotoUploaded, let userCachedPhotoData = self?.userSessionProvider.userCachedPhotoData  {
                    self?.avatar = UIImage(data: userCachedPhotoData)
                }
            }
            .store(in: &cancellables)

        // User coins stream
        coinCount = coinCollectProvider.cachedCoinsCount ?? .zero
        userSessionProvider.userCollectedCoinsAmountStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coinsAmount in
                self?.coinCount = coinsAmount
            }
            .store(in: &cancellables)
    }
}
