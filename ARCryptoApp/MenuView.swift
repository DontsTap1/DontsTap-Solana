//
//  MenuView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI

enum MenuViewAction: Int, CaseIterable {
    case openProfile
    case openDoubleCoin
    case openCashout

    var title: String {
        switch self {
        case .openProfile:
            return "Profile"
        case .openDoubleCoin:
            return "Double Coin"
        case .openCashout:
            return "Cashout"
        }
    }
}

struct MenuView: View {
    @Binding var showAR: Bool
    @Binding var buttonCentre: CGPoint

    @State private var showSignIn = false
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        VStack {
            Spacer()

            GeometryReader { geometry in
                Button {
                    let frame = geometry.frame(in: .global)
                    buttonCentre = CGPoint(
                        x: frame.midX,
                        y: frame.midY
                    )

                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAR.toggle()
                    }
                } label: {
                    Text("DONT STAP")
                        .bold()
                        .foregroundStyle(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.purple)
                                .frame(width: 100, height: 100)
                        }
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
            .frame(height: 200)


            Spacer()

            HStack(spacing: 20) {
                ForEach(MenuViewAction.allCases, id: \.rawValue) { action in
                    Button(action: {
                        if !authManager.isAuthenticated {
                            showSignIn.toggle()
                        }
                        else {
                            switch action {
                            case .openProfile:
                                print("Open Profile")
                            case .openDoubleCoin:
                                print("Open Double Coin")
                            case .openCashout:
                                print("Open Cashout")
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 60, height: 60)
                            .overlay {
                                switch action {
                                case .openProfile:
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.white)
                                case .openDoubleCoin:
                                    Image(systemName: "dollarsign.circle")
                                        .foregroundColor(.white)
                                case .openCashout:
                                    Image(systemName: "arrow.up.circle")
                                        .foregroundColor(.white)
                                }
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    MenuView(showAR: .constant(false), buttonCentre: .constant(.zero))
}
