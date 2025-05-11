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
    @State private var scaleMainButtonAnimation = false

    var body: some View {
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
                        VStack(spacing: 15) {
                            Image("dontStapButton")
                                .resizable()
                                .frame(width: 190, height: 190)
                                .scaleEffect(scaleMainButtonAnimation ? 1.5 : 1.0)

                            Text("TAP DONT STAP TO START THE GAME")
                                .font(.headline)
                                .underline()
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                }
                .frame(height: 200)
                .onAppear {
                    let delay = 0.5
                    let reverseDelay = delay + 0.3
                    withAnimation(.easeInOut.delay(delay)) {
                        scaleMainButtonAnimation.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + reverseDelay) {
                        withAnimation(.easeInOut) {
                            self.scaleMainButtonAnimation.toggle()
                        }
                    }
                }

                Spacer()

                if viewModel.availableMenuActionLoading {
                    RoundedRectangle(cornerRadius: 5.0)
                        .foregroundStyle(Color.menuColors)
                        .blur(radius: 3.0)
                        .frame(width: 330, height: 60)
                        .overlay {
                            ProgressView()
                                .tint(Color.white)
                        }
                }
                else {
                    HStack(spacing: 30) {
                        ForEach(viewModel.availableActions, id: \.rawValue) { action in
                            Button(action: {
                                viewModel.onMenuButtonTap(action: action)
                            }) {
                                switch action {
                                    case .openProfile:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(Color.menuColors)
                                            .frame(width: 60, height: 60)
                                            .shadow(radius: 5.0)
                                    case .openDoubleCoin:
                                        ZStack {
                                            Circle()
                                                .fill(Color.menuColors)
                                                .frame(width: 60, height: 60)
                                                .shadow(radius: 5.0)

                                            Text("X2")
                                                .font(.title3)
                                                .bold()
                                                .foregroundColor(Color.gradientColorTwo)
                                        }
                                    case .openCashout:
                                        Image(systemName: "dollarsign.circle.fill")
                                            .resizable()
                                            .foregroundColor(Color.menuColors)
                                            .frame(width: 60, height: 60)
                                            .shadow(radius: 5.0)
                                    case .openExchange:
                                        Image(systemName: "bitcoinsign.circle.fill")
                                            .resizable()
                                            .foregroundColor(Color.menuColors)
                                            .frame(width: 60, height: 60)
                                            .shadow(radius: 5.0)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom)
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
                    case .openExchange:
                        ExchangeView()
                }
            }
        })
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
