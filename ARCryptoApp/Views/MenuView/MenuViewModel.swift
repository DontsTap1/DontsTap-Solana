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

    @Published var presentationAction: MenuViewAction? = nil
    @Published var isPresentationActive = false
    @Published var showSignIn = false

    @Inject
    var userSessionProvider: UserSessionProvider

    func onAppear() {

    }

    func onMenuButtonTap(action: MenuViewAction) {
        if userSessionProvider.isGuestUser {
            showSignIn.toggle()
        }
        else {
            presentationAction = action
            isPresentationActive.toggle()
        }
    }
}
