//
//  SignInView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//


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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Sign In") {
                    authManager.signIn(email: email, password: password)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Sign In")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
