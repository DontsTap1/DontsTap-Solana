//
//  ExchangeView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 31.03.2025.
//

import SwiftUI
@preconcurrency import WebKit

struct ExchangeView: View {
    @State private var isLoading: Bool = true

    var body: some View {
        WebView(isLoading: $isLoading)
            .ignoresSafeArea()
            .loadingView(isPresented: $isLoading)
    }
}

private struct WebView: UIViewRepresentable {
    @Binding var isLoading: Bool  // Track loading state

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.allowsBackForwardNavigationGestures = true

        if let url = URL(string: "https://guardarian.com/calculator/v1?partner_api_token=ff91b7de-a2d8-4a58-8384-338151c53cb8&type=narrow&swap_enabled=true&default_crypto_currency=SOL&body_background=rgb(72,28,83)&calc_background=rgb(72,28,83)&button_background=rgb(75,138,197)&button_background_disabled=rgb(75,138,187)") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Show loader when page starts loading
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        // Hide loader when page finishes loading
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        // Also handle errors (hide loader if error occurs)
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

#Preview {
    ExchangeView()
}
