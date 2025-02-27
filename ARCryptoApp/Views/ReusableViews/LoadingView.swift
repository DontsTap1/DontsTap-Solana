//
//  LoadingView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 26.02.2025.
//

import SwiftUI

/// Loading View Modifier
struct LoadingViewModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                // Full-screen overlay with blur effect
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // Blurred background
                VisualEffectBlur(style: .systemUltraThinMaterial)
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                    )
            }
        }
    }
}

extension View {
    func loadingView(isPresented: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isPresented: isPresented))
    }
}
