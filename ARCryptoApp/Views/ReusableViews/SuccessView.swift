//
//  SuccessView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 26.02.2025.
//

import SwiftUI

/// Reusable Success View Modifier
struct SuccessViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        ZStack {
                            // Full-screen overlay with blur effect
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .transition(.opacity)

                            // Blurred background
                            VisualEffectBlur(style: .systemUltraThinMaterial)
                                .ignoresSafeArea()

                            // Success modal
                            VStack(spacing: 25) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)

                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)

                                if let message = message {
                                    Text(message)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                }

                                Button("OK") {
                                    isPresented = false
                                    onDismiss?()
                                }
                                .padding()
                                .frame(maxWidth: 150)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            .frame(maxWidth: 300)
                            .shadow(radius: 10)
                            .transition(.scale)
                        }
                    }
                }
            )
            .animation(.easeInOut, value: isPresented)
    }
}

/// View extension to easily apply the modifier
extension View {
    func successView(isPresented: Binding<Bool>, title: String, message: String? = nil, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(SuccessViewModifier(isPresented: isPresented, title: title, message: message, onDismiss: onDismiss))
    }
}
