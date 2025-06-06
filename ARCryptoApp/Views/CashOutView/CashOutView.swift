//
//  CashOutView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI

struct CashOutView: View {
    private enum Constants {
        static let twitterURL = URL(string: "https://twitter.com/TapDonts")
        static let telegramURL = URL(string: "https://t.me/DONTSTAPPP")
    }
    var body: some View {
        BackgroundGradientView {
            VStack(spacing: 20) {
                CoinAmountView()

                Text("Please follow us on social media to know when cash out become available")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack(spacing: 40) {
                    if let twitterURL = Constants.twitterURL {
                        Link(destination: twitterURL) {
                            Image("twitter-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        }
                    }

                    if let telegramURL = Constants.telegramURL {
                        Link(destination: telegramURL) {
                            Image("telegram-icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CashOutView()
}
