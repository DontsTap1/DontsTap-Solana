//
//  PrimaryTextFieldView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 27.02.2025.
//

import SwiftUI

struct PrimaryTextFieldView: View {
    let title: String
    @Binding var text: String
    let errorMessage: String?
    @Binding var isValid: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)

            TextField("", text: $text)
                .padding(.all, 10)
                .background(Color.white)
                .foregroundStyle(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isValid ? Color.black : Color.red, lineWidth: 2)
                )
                .cornerRadius(8)

            if let errorMessage = errorMessage, !isValid {
                Text(errorMessage)
                    .foregroundColor(.black)
                    .shadow(color: .white, radius: 2.0)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
