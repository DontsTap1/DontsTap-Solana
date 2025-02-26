//
//  MenuView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI

struct MenuView: View {
    @Binding var showAR: Bool
    @Binding var buttonCentre: CGPoint

    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var viewModel = MenuViewModel()

    var body: some View {
        NavigationView {
            BackgroundGradientView {
                VStack {
                    Spacer()

                    GeometryReader { geometry in
                        Button {
                            let frame = geometry.frame(in: .global)
                            buttonCentre = CGPoint(
                                x: frame.midX,
                                y: frame.midY
                            )

                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAR.toggle()
                            }
                        } label: {
                            Text("DONT STAP")
                                .bold()
                                .foregroundStyle(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(.purple)
                                        .frame(width: 100, height: 100)
                                }
                        }
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                    }
                    .frame(height: 200)

                    Spacer()

                    HStack(spacing: 20) {
                        ForEach(MenuViewModel.MenuViewAction.allCases, id: \.rawValue) { action in
                            Button(action: {
                                viewModel.onMenuButtonTap(action: action)
                            }) {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        switch action {
                                        case .openProfile:
                                            Image(systemName: "person.circle")
                                                .foregroundColor(.white)
                                        case .openDoubleCoin:
                                            Image(systemName: "dollarsign.circle")
                                                .foregroundColor(.white)
                                        case .openCashout:
                                            Image(systemName: "arrow.up.circle")
                                                .foregroundColor(.white)
                                        }
                                    }
                            }
                        }
                    }
                }
                .onAppear(perform: viewModel.onAppear)
            }
            .sheet(isPresented: $viewModel.showSignIn) {
                SignInView()
                    .environmentObject(authManager)
            }
        }
        .navigationDestination(isPresented: $viewModel.isPresentationActive, destination: {
            if let action = viewModel.presentationAction {
                switch action {
                case .openProfile:
                    ProfileView()
                case .openDoubleCoin:
                    CoinMultiplierView()
                case .openCashout:
                    CashOutView()
                }
            }
        })
    }
}

#Preview {
    MenuView(showAR: .constant(false), buttonCentre: .constant(.zero))
}
