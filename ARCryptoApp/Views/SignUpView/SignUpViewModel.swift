//
//  SignUpViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 26.02.2025.
//

import Combine
import SwiftUI
import PhotosUI
import AuthenticationServices

class SignUpViewModel: ObservableObject {
    enum SignUpErrors: UserRepresentableError {
        case invalidNickname

        var userErrorText: String {
            switch self {
            case .invalidNickname:
                return "Invalid nickname."
            }
        }

        var userErrorDescription: String? {
            switch self {
            case .invalidNickname:
                return "Nickname must be at least 3 characters long and should contain at least one letter."
            }
        }
    }

    // MARK: - Published properties
    // Nickname
    @Published var nickname: String = "" {
        didSet {
            validateNickname()
        }
    }
    @Published var nicknameErrorMessage: String = ""
    @Published var isNicknameValid: Bool = true
    @Published var isSubmitButtonEnabled = false

    // Image selection
    @Published var selectedImage: UIImage?
    @Published var isPhotoSourceActionSheetPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    @Published var isCameraPresented: Bool = false
    @Published var isFilePickerPresented: Bool = false

    // Loading, errors, success messages
    @Published var isLoading: Bool = false
    @Published var signUpErrorPresented: Bool = false
    @Published var signUpError: UserRepresentableError = GenericErrors.generic
    @Published var successMessagePresented = false
    @Published var successMessageText = ""

    // MARK: - Injected properties
    @Inject
    private var authenticationProvider: AuthenticationProvider

    // MARK: - Private properties
    private var cancellableSignUp: AnyCancellable?

    func handleImageSelection(_ image: UIImage) {
        selectedImage = image
    }

    func validateNickname() {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        if trimmed.count < 3 {
            isNicknameValid = false
            nicknameErrorMessage = "Nickname must be at least 3 characters long."
        } else if !trimmed.contains(where: { $0.isLetter }) {
            isNicknameValid = false
            nicknameErrorMessage = "Nickname should contain at least one letter."
        } else if trimmed.contains(where: { $0.isPunctuation }) {
            isNicknameValid = false
            nicknameErrorMessage = "Nickname should NOT contain punctuation symbols"
        }
        else {
            isNicknameValid = true
            nicknameErrorMessage = ""
        }
        isSubmitButtonEnabled = isNicknameValid
    }

    func didTapSubmitButton() {
        guard isNicknameValid else {
            signUpError = SignUpErrors.invalidNickname
            signUpErrorPresented = true
            return
        }
        let nickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true

        cancellableSignUp = authenticationProvider.authenticateSession(
            nickname: nickname,
            profileImage: selectedImage?.jpegData(compressionQuality: 0.6)
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            switch completion {
            case .finished:
                break
            case .failure(let error):
                if let error = error as? UserRepresentableError {
                    self?.signUpError = error
                }
                else {
                    self?.signUpError = GenericErrors.generic
                }
                self?.signUpErrorPresented = true
            }
        }, receiveValue: { [weak self] result in
            if result {
                self?.successMessagePresented.toggle()
                self?.successMessageText = "Congrats your sign up is successful!"
            }
            else {
                self?.signUpErrorPresented.toggle()
                self?.signUpError = GenericErrors.generic
            }
        })
    }
}

class MockAppAuthProvider: AuthenticationProvider {
    func authenticationAppLaunch() {

    }

    func authenticate(with authorization: ASAuthorization) -> AnyPublisher<AuthenticationStatus, any Error> {
        return Fail(outputType: AuthenticationStatus.self, failure: GenericErrors.generic)
            .eraseToAnyPublisher()
    }

    func authenticateSession(nickname: String, profileImage: Data?) -> AnyPublisher<Bool, any Error> {
        return Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
}
