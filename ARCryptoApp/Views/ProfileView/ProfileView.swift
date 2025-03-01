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
                    }
                }

                Spacer()

                VStack {
                    Image("coinIcon")
                        .resizable()
                        .frame(width: 50, height: 50)

                    Text("\(viewModel.coinCount)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.yellow)

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
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        viewModel.handleImageSelection(image)
                    }
                case .failure:
                    viewModel.errorText = GenericErrors.generic.userErrorText
                    viewModel.errorPresented.toggle()
                }
            }
            .errorView(isPresented: $viewModel.errorPresented, title: viewModel.errorText)
            .loadingView(isPresented: $viewModel.isLoading)
        }
    }
}

#Preview {
    ProfileView()
}
