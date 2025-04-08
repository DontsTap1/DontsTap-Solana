//
//  CloseButton.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 08.04.2025.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
        }
    }
}

struct CloseButtonModifier: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .tint(.white)
    }
}

extension View {
    func withCustomCloseButton() -> some View {
        modifier(CloseButtonModifier())
    }
}
