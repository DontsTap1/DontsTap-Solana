//
//  ExchangeView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 31.03.2025.
//

import SwiftUI
@preconcurrency import WebKit

struct ExchangeView: View {
    let jsWidgetHTML = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    height: 100%;
                    width: 100%;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    background-color: transparent;
                }
                iframe {
                    width: 100%;
                    height: 100%;
                    border-radius: 32px;
                    border: none;
                }
            </style>
        </head>
        <body>
            <iframe src="https://guardarian.com/calculator/v1?partner_api_token=ff91b7de-a2d8-4a58-8384-338151c53cb8&type=narrow&swap_enabled=true&default_crypto_currency=SOL&body_background=rgb(72,28,83)&calc_background=rgb(72,28,83)&button_background=rgb(75,138,197)&button_background_disabled=rgb(75,138,187)" 
             allowfullscreen style="background: transparent;">
            </iframe>
        </body>
        </html>
        """

    @State private var isLoading: Bool = true

    var body: some View {
        WebView(htmlString: jsWidgetHTML, isLoading: $isLoading)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity) // Adjust to fit your widget size
            .ignoresSafeArea()
            .loadingView(isPresented: $isLoading)
    }
}

private struct WebView: UIViewRepresentable {
    let htmlString: String
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

        webView.loadHTMLString(htmlString, baseURL: nil)
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
