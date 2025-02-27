//
//  SignInView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import AuthenticationServices
import SwiftUI

// MARK: - Auth State
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false

    func signIn(email: String, password: String) {
        // Implement your authentication logic here
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
    }
}

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @StateObject private var viewModel = SignInViewModel()

    var body: some View {
        NavigationStack {
            NavigationView {
                BackgroundGradientView {
                    VStack {
                        Spacer()

                        // Coin icon and count
                        VStack(spacing: 5) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.yellow)

                            Text("0")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.yellow)
                        }

                        Spacer()

                        // Description text
                        VStack(alignment: .leading, spacing: 5) {
                            Text("After sign in you will be able:")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)

                            ForEach([
                                "Store your collected coins on cloud",
                                "Get access to coin doubler",
                                "Upload your photo",
                                "Appear on the score record table"
                            ], id: \.self) { item in
                                Text("- \(item)")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer()

                        // Sign in button
                        SignInWithAppleButton(.signIn) { appleIdRequest in
                            appleIdRequest.requestedScopes = [.email]
                        } onCompletion: { result in
                            viewModel.onAuthenticationRequest(result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 20)
                    }
                    .errorView(isPresented: $viewModel.showErrorAlert, error: GenericErrors.generic)
                    .loadingView(isPresented: $viewModel.isLoading)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.white)
                }
            }
            .navigationDestination(isPresented: $viewModel.navigationToSign, destination: {
                SignUpView()
            })
            .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    SignInView()
}
