//
//  ErrorView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 16.02.2025.
//

/*
 Rectangle error modal view with rounded corner.
 - icon image with cross
 - label which displays a error description.
 - button to dismiss the modal view
 */

import SwiftUI

struct ErrorView: View {
    @State
    private var title: String = ""
    @State
    private var description: String = ""
    @State
    private var dismissButtonTitle = "Dismiss"
    @Binding
    var isPresented: Bool
    let onDismiss: (() -> Void)?

    init(
        title: String,
        description: String,
        dismissButtonTitle: String = "",
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 20) {
            // Error Icon
            Image(systemName: "xmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            // Title
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            // Description
            Text(description)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal)

            
            // Dismiss Button - Only show if onDismiss is provided
            Button {
                isPresented.toggle()
                onDismiss?()
            } label: {
                Text(dismissButtonTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 40)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding(24)
        .background(Color.orange)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

extension View {
    func customErrorAlert(
        title: String,
        description: String,
        dismissButtonTitle: String? = nil,
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            if let dismissButtonTitle {
                ErrorView(
                    title: title,
                    description: description,
                    dismissButtonTitle: dismissButtonTitle,
                    isPresented: isPresented,
                    onDismiss: onDismiss
                )
            }
            else {
                ErrorView(
                    title: title,
                    description: description,
                    isPresented: isPresented,
                    onDismiss: onDismiss
                )
            }
        }
    }

    func customErrorAlert(
        error: UserRepresentableError,
        dismissButtonTitle: String? = nil,
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?
    ) -> some View {
#warning("Fix custom alert presentation")
        ZStack {
            self
            if isPresented.wrappedValue {
                if let dismissButtonTitle {
                    ErrorView(
                        title: error.userErrorText,
                        description: error.userErrorDescription ?? "",
                        dismissButtonTitle: dismissButtonTitle,
                        isPresented: isPresented,
                        onDismiss: onDismiss
                    )
                }
                else {
                    ErrorView(
                        title: error.userErrorText,
                        description: error.userErrorDescription ?? "",
                        isPresented: isPresented,
                        onDismiss: onDismiss
                    )
                }
            }
        }
    }
}

// Preview
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with dismiss button
            ErrorView(
                title: "Connection Error",
                description: "Please check your internet connection and try again.",
                isPresented: .constant(true),
                onDismiss: {}
            )
            .previewDisplayName("Error View")

            // Preview without dismiss button
            ErrorView(
                title: "Invalid Input",
                description: "The provided information is not valid. Please verify and try again.",
                isPresented: .constant(false)
            )
            .previewDisplayName("Error View Two")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
