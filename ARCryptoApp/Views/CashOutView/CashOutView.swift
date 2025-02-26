//
//  CashOutView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI

struct CashOutView: View {
    var body: some View {
        BackgroundGradientView {
            VStack(spacing: 20) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                
                Text("1234")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("You have earned 1234 coins. Use them to cash out or exchange for rewards. Keep earning more coins by participating in activities.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack(spacing: 40) {
                    Link(destination: URL(string: "https://twitter.com")!) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "link")
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Link(destination: URL(string: "https://telegram.org")!) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "link")
                                    .foregroundColor(.white)
                            )
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
