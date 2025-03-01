//
//  CustomToolbar.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 01.03.2025.
//

import SwiftUI
import Combine

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
    }
}

struct TopToolbarModifier: ViewModifier {
    @StateObject private var viewModel = TopToolbarViewModel()

    func body(content: Content) -> some View {
        content
            .toolbar {
                if viewModel.shouldRenderUserData {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(spacing: 8) {
                            if let avatar = viewModel.avatar {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 25, height: 25)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.yellow, lineWidth: 1)
                                    )
                            }

                            if let nickname = viewModel.nickname, !nickname.isEmpty {
                                Text(nickname)
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 5) {
                        Image("coinIcon") // Replace with coin image
                            .resizable()
                            .frame(width: 25, height: 25)

                        Text("\(viewModel.coinCount)")
                            .font(.title)
                            .bold()
                            .foregroundColor(.yellow)
                    }
                }
            }
    }
}

extension View {
    func topToolbar() -> some View {
        self.modifier(TopToolbarModifier())
    }
}
