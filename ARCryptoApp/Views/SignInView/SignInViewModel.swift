//
//  SignInViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 06.02.2025.
//

import AuthenticationServices
import Combine
import Foundation
import SwiftUI

class SignInViewModel: ObservableObject {
    init() {}

    @Inject
    private var authenticationProvider: AuthenticationProvider

    @Published var navigationToSign: Bool = false
    @Published var showErrorAlert = false
    @Published var isLoading = false
    var dismissEnvironmentVariable: DismissAction?

    private var cancellable: Set<AnyCancellable> = []

    func onAuthenticationRequest(_ authorizationResult: (Result<ASAuthorization, any Error>)) {
        switch authorizationResult {
        case .success(let authorization):
            isLoading = true
            authenticationProvider.authenticate(with: authorization)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self?.showErrorAlert.toggle()
                    }
                } receiveValue: { [weak self] status in
                    guard let self else {
                        return
                    }
                    
                    switch status {
                    case .signedIn:
                        dismissEnvironmentVariable?()
                    case .redirectToSignUp:
                        self.navigationToSign.toggle()
                    }
                }
                .store(in: &cancellable)
        case .failure:
            showErrorAlert.toggle()
        }
    }
}
