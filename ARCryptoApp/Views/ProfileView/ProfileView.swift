//
//  ProfileView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BackgroundGradientView {
            VStack {
                ZStack {
                    AvatarPhotoView(
                        selectedImage: $viewModel.userAvatar,
                        isPhotoSourceActionSheetPresented: $viewModel.isPhotoSourceActionSheetPresented,
                        isCameraPresented: $viewModel.isCameraPresented,
                        isImagePickerPresented: $viewModel.isImagePickerPresented,
                        isFilePickerPresented: $viewModel.isFilePickerPresented
                    )
                    .overlay {
                        if viewModel.isAvatarLoading {
                            ProgressView()
                                .tint(.white)
                                .progressViewStyle(.automatic)
                                .scaleEffect(1.5)
                                .frame(width: 150, height: 150)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        if viewModel.isAvatarLoadingFailed {
                            VStack {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.red)

                                Text("Failed to load")
                                    .foregroundStyle(Color.white)
                            }
                            .frame(width: 150, height: 150)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .allowsHitTesting(false)
                        }
                    }
                }

                Spacer()

                VStack {
                    CoinAmountView()

                    if !viewModel.nickname.isEmpty {
                        Text("nickname: \(viewModel.nickname)")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }

                Spacer()

                PrimaryButtonView(title: "SIGN OUT", isEnabled: true) {
                    viewModel.signOut()
                    dismiss()
                }
                .padding(.horizontal, 20)

                Button(action: {
                    viewModel.deleteAccount()
                }) {
                    Text("DELETE ACCOUNT")
                        .foregroundColor(.white)
                        .font(.body)
                }
                .padding(.top, 10)
                .onReceive(viewModel.$deleteAccountSuccess, perform: { accountDeleted in
                    if accountDeleted {
                        dismiss()
                    }
                })
            }
            .padding()
            .fullScreenCover(isPresented: $viewModel.isImagePickerPresented) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    viewModel.handleImageSelection(image)
                }
            }
            .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
                ImagePicker(sourceType: .camera) { image in
                    viewModel.handleImageSelection(image)
                }
            }
            .fileImporter(isPresented: $viewModel.isFilePickerPresented, allowedContentTypes: [.image]) { result in
                switch result {
                case .success(let url):
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        viewModel.handleImageSelection(image)
                    }
                case .failure:
                        viewModel.error = GenericErrors.generic
                        viewModel.errorPresented.toggle()
                }
            }
            .errorView(isPresented: $viewModel.errorPresented, error: viewModel.error)
            .loadingView(isPresented: $viewModel.isLoading)
        }
    }
}

#Preview {
    ProfileView()
}
