//
//  ContentView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 11.01.2025.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var showAR = false
    @State private var buttonCenter: CGPoint = .zero

    var body: some View {
        ZStack {
            MenuView(showAR: $showAR, buttonCentre: $buttonCenter)

            if showAR {
                GameView(showAR: $showAR)
                    .modifier(
                        ButtonDissolveTransition(
                            isPresented: showAR,
                            center: buttonCenter
                        )
                    )
            }
        }
    }
}

struct ButtonDissolveTransition: ViewModifier {
    let isPresented: Bool
    let center: CGPoint

    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { geometry in
                    Circle()
                        .scale(isPresented ? 3.5 : 0.001)
                        .position(center)
                        .animation(.easeInOut(duration: 0.4), value: isPresented)
                }
            )
    }
}

#Preview {
    ContentView()
}
