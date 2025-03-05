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
    @State private var coinAnimationToggle = false

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                // Blurred background
                VisualEffectBlur(style: .systemUltraThinMaterialLight)
                    .ignoresSafeArea()
                
                VStack {
                    Image("coinIcon") // Replace with coin image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotation3DEffect(
                            .degrees(coinAnimationToggle ? 0.0 : 360.0),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                        .animation(
                            .interpolatingSpring(duration: 0.55).repeatForever(autoreverses: true),
                            value: coinAnimationToggle
                        )
                    Text("coins are running...")
                        .foregroundStyle(Color.white)
                        .font(.title)
                }
                .onAppear {
                    coinAnimationToggle.toggle()
                }
            }
        }
    }
}

extension View {
    func loadingView(isPresented: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isPresented: isPresented))
    }
}

#Preview(body: {
    BackgroundGradientView {
        Color.clear
            .loadingView(isPresented: .constant(true))
    }
})
