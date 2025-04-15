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
    @Published var shouldRenderUserData = true
    @Published var isLoadingUserData = false
    
    private var avatarData: Data? {
        didSet {
            if let avatarData {
                avatar = UIImage(data: avatarData)
            }
            else {
                avatar = nil
            }
        }
    }

    @Inject
    private var userSessionProvider: UserSessionProvider
    @Inject
    var coinCollectProvider: CoinCollectStoreProvider

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupStreams()
        fetchUserInfo()
    }

    private func setupStreams() {
        // User stream to observe change of user status
        userSessionProvider.userStream
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] user in
                guard let self else { return }
                if let nickname = user?.nickname {
                    self.nickname = nickname
                }
                if let userStatus = user?.status {
                    if userStatus == .signedIn {
                        fetchUserInfo()
                    }
                    withAnimation {
                        self.shouldRenderUserData = userStatus == .signedIn
                    }
                }
                print("### user stream did update")
            })
            .store(in: &cancellables)

        // User photo upload stream to observe updates
        userSessionProvider.userDidUploadPhotoStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPhotoUploaded in
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

    private func fetchUserInfo() {
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
                self?.avatarData = userInfo.photo
            })
            .store(in: &cancellables)
    }
}
