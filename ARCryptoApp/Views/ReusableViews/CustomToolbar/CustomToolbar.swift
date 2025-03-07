//
//  CustomToolbar.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 01.03.2025.
//

import SwiftUI
import Combine

struct MainToolBar: ToolbarContent {
    @StateObject private var viewModel = TopToolbarViewModel()
    @State private var coinAnimationToggle = false

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            if viewModel.shouldRenderUserData {
                HStack(spacing: 8) {
                    if viewModel.isLoadingUserData {
                        Circle()
                            .frame(width: 25.0, height: 25.0)
                            .foregroundStyle(.yellow)
                            .blur(radius: 3.0)

                        Rectangle()
                            .frame(width: 100.0, height: 25.0)
                            .foregroundStyle(.yellow)
                            .blur(radius: 3.0)
                    }
                    else {
                        if let avatar = viewModel.avatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 1)
                                )
                        }

                        if let nickname = viewModel.nickname, !nickname.isEmpty {
                            Text(nickname)
                                .font(.title)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack(spacing: 5) {
                Image("coinIcon") // Replace with coin image
                    .resizable()
                    .frame(width: 25, height: 25)
                    .rotation3DEffect(
                        .degrees(coinAnimationToggle ? 0.0 : 360.0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    .animation(
                        .interpolatingSpring(duration: 0.6).repeatForever(autoreverses: true),
                        value: coinAnimationToggle
                    )
                    .onAppear {
                        coinAnimationToggle.toggle()
                    }

                Text("\(viewModel.coinCount)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct TopToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                MainToolBar()
            }
    }
}

extension View {
    func topToolbar() -> some View {
        self.modifier(TopToolbarModifier())
    }
}
