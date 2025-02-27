//
//  SignUpView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 06.02.2025.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) private var presentationMode
    private var onDismiss: () -> ()

    init(onDismiss: @escaping () -> ()) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        BackgroundGradientView {
            VStack(spacing: 10) {
                AvatarPhotoView(
                    selectedImage: $viewModel.selectedImage,
                    isPhotoSourceActionSheetPresented: $viewModel.isPhotoSourceActionSheetPresented,
                    isCameraPresented: $viewModel.isCameraPresented,
                    isImagePickerPresented: $viewModel.isImagePickerPresented,
                    isFilePickerPresented: $viewModel.isFilePickerPresented
                )

                Spacer()

                PrimaryTextFieldView(
                    title: "Enter nickname",
                    text: $viewModel.nickname,
                    errorMessage: viewModel.nicknameErrorMessage,
                    isValid: $viewModel.isNicknameValid
                )
                .padding(.horizontal, 20)

                Spacer()

                PrimaryButtonView(
                    title: "Submit",
                    isEnabled: viewModel.isSubmitButtonEnabled
                ) {
                    viewModel.didTapSubmitButton()
                }
                .padding(.horizontal, 20)
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
                    viewModel.signUpError = GenericErrors.generic
                    viewModel.signUpErrorPresented.toggle()
                }
            }
            .loadingView(isPresented: $viewModel.isLoading)
            .errorView(isPresented: $viewModel.signUpErrorPresented, error: viewModel.signUpError)
            .successView(isPresented: $viewModel.successMessagePresented, title: viewModel.successMessageText, onDismiss: {
                onDismiss()
            })
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.white)
                    }
                }
            }

        }
    }
}

#Preview {
    SignUpView {
        // no dimiss
    }
}
