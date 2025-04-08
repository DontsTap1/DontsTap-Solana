//
//  MenuViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 05.02.2025.
//

import SwiftUICore

class MenuViewModel: ObservableObject {
    enum MenuViewAction: Int, CaseIterable {
        case openProfile
        case openDoubleCoin
        case openCashout
        case openExchange

        var title: String {
            switch self {
            case .openProfile:
                return "Profile"
            case .openDoubleCoin:
                return "Double Coin"
            case .openCashout:
                return "Cashout"
            case .openExchange:
                return "Exchange"
            }
        }
    }

    @Published var presentationAction: MenuViewAction?
    @Published var isPresentationActive = false
    @Published var showSignIn = false

    @Inject
    var userSessionProvider: UserSessionProvider

    func onMenuButtonTap(action: MenuViewAction) {
        presentationAction = action
        if userSessionProvider.isGuestUser, action != .openExchange {
            showSignIn.toggle()
        }
        else {
            isPresentationActive.toggle()
        }
    }

    func handleSignInViewDismiss() {
        if !userSessionProvider.isGuestUser,
           presentationAction != nil {
            isPresentationActive.toggle()
        }
    }
}
