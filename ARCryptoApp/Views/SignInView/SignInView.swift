//
//  SignInView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @StateObject private var viewModel = SignInViewModel()
    private let descriptionText =
    """
    - Store your collected coins on cloud
    - Get access to coin doubler
    - Upload your photo
    - Appear on the score record table
    """

    var body: some View {
        NavigationStack {
            BackgroundGradientView {
                VStack {
                    Spacer()

                    CoinAmountView()
                        .padding(.top, 10)

                    Spacer()

                    // Description text
                    VStack(alignment: .leading, spacing: 5) {
                        Text("After sign in you will be able:")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text(descriptionText)
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 15)

                    // Sign in button
                    SignInWithAppleButton(.signIn) { appleIdRequest in
                        appleIdRequest.requestedScopes = [.email]
                    } onCompletion: { result in
                        viewModel.onAuthenticationRequest(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                }
                .errorView(isPresented: $viewModel.showErrorAlert, error: GenericErrors.generic)
                .loadingView(isPresented: $viewModel.isLoading)
                .onAppear {
                    viewModel.dismissEnvironmentVariable = dismiss
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
                SignUpView {
                    dismiss()
                }
            })
            .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    SignInView()
}
