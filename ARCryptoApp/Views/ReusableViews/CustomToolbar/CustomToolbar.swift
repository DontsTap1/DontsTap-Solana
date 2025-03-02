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

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            if viewModel.shouldRenderUserData {
                HStack(spacing: 8) {
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
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack(spacing: 5) {
                Image("coinIcon") // Replace with coin image
                    .resizable()
                    .frame(width: 25, height: 25)

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
