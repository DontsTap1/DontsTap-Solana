//
//  SignInViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 06.02.2025.
//

import AuthenticationServices
import Combine
import Foundation

class SignInViewModel: ObservableObject {
    init() {}

    @Inject
    private var authenticationProvider: AuthenticationProvider

    @Published var navigationToSign: Bool = false
    @Published var showErrorAlert = false

    private var cancellable: Set<AnyCancellable> = []

    func onAuthenticationRequest(_ authorizationResult: (Result<ASAuthorization, any Error>)) {
        switch authorizationResult {
        case .success(let authorization):
            authenticationProvider.authenticate(with: authorization)
                .sink { completion in
                    return
                } receiveValue: { [weak self] status in
                    guard let self else {
                        return
                    }
                    
                    switch status {
                    case .signedIn:
                        print("already sign in")
                    case .redirectToSignUp:
                        self.navigationToSign.toggle()
                    }
                }
                .store(in: &cancellable)
        case .failure(let failure):
            showErrorAlert.toggle()
            break
        }
    }
}
