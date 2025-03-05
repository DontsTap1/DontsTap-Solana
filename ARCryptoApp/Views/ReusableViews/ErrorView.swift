import SwiftUI

/// Reusable Error View Modifier
struct ErrorViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        ZStack {
                            // Full-screen overlay with blur effect
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .transition(.opacity)

                            // Blurred background
                            VisualEffectBlur(style: .systemUltraThinMaterial)
                                .ignoresSafeArea()

                            // Error modal
                            VStack(spacing: 25) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .foregroundStyle(Color.red)
                                    .frame(width: 30, height: 30)
                                    .shadow(radius: 2.5)

                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)

                                if let message = message {
                                    Text(message)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                }

                                Button("Dismiss") {
                                    isPresented = false
                                    onDismiss?()
                                }
                                .padding()
                                .frame(maxWidth: 150)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.menuColors))
                            .frame(maxWidth: 300)
                            .shadow(radius: 10)
                            .transition(.scale)
                        }
                    }
                }
            )
            .animation(.easeInOut, value: isPresented)
    }
}

/// SwiftUI wrapper for UIVisualEffectView to achieve a native blur effect
struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

/// View extension to easily apply the modifier
extension View {
    func errorView(isPresented: Binding<Bool>, title: String, message: String? = nil, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorViewModifier(isPresented: isPresented, title: title, message: message, onDismiss: onDismiss))
    }

    func errorView(isPresented: Binding<Bool>, error: UserRepresentableError, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorViewModifier(isPresented: isPresented, title: error.userErrorText, message: error.userErrorDescription, onDismiss: onDismiss))
    }
}

#Preview {
    BackgroundGradientView {
        Color.clear
            .errorView(isPresented: .constant(true), error: GenericErrors.generic)
    }
}
