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

    @StateObject private var viewModel = MenuViewModel()
    @State private var rotate = false

    var body: some View {
        NavigationStack {
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
                .sheet(isPresented: $viewModel.showSignIn, onDismiss: {
                    viewModel.handleSignInViewDismiss()
                }, content: {
                    SignInView()
                })
                .navigationDestination(isPresented: $viewModel.isPresentationActive, destination: {
                    if let action = viewModel.presentationAction {
                        switch action {
                        case .openProfile:
                            ProfileView()
                                .withCustomBackButton()
                        case .openDoubleCoin:
                            CoinMultiplierView()
                                .withCustomBackButton()
                        case .openCashout:
                            CashOutView()
                                .withCustomBackButton()
                        }
                    }
                })
            }
            .topToolbar()
        }
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
        }
    }
}

struct BackButtonModifier: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .tint(.white)
    }
}

extension View {
    func withCustomBackButton() -> some View {
        modifier(BackButtonModifier())
    }
}

#Preview {
    MenuView(showAR: .constant(false), buttonCentre: .constant(.zero))
}
