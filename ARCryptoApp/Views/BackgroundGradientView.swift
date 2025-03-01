import SwiftUI

struct BackgroundGradientView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // 76 41 221
            // 135 60 154
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(simplifiedRed: 76, green: 41, blue: 221),
                    Color(simplifiedRed: 135, green: 60, blue: 154)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
    }
}
