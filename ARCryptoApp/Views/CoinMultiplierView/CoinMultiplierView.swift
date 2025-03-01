//
//  CoinMultiplierView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI

struct CoinMultiplierView: View {
    @StateObject private var viewModel = CoinMultiplierViewModel()

    var body: some View {
        BackgroundGradientView {
            VStack(spacing: 20) {
                CoinAmountView()

                Spacer()

                Text("Wanna double your collected coins?")
                    .textCase(.uppercase)
                    .font(.title)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)

                Button(action: {
                    viewModel.openShop()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text("sTAP sHOP")
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                }
                .background(Color.yellow)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()

                PrimaryTextFieldView(
                    title: "Enter Promocode",
                    text: $viewModel.promocode,
                    errorMessage: nil,
                    isValid: .constant(true)
                )
                .padding(.horizontal, 20)

                PrimaryButtonView(title: "SUBMIT", isEnabled: true) {
                    viewModel.submitPromocode()
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .loadingView(isPresented: $viewModel.isLoading)
            .errorView(isPresented: $viewModel.errorPresented, error: viewModel.error)
            .successView(isPresented: $viewModel.successPresented, title: viewModel.successText)
        }
    }
}

#Preview {
    CoinMultiplierView()
}
