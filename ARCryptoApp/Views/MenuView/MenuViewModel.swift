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
    @Published private(set) var isExchangeButtonVisible = false
    @Published var availableMenuActionLoading = true

    @Inject
    var userSessionProvider: UserSessionProvider
    
    @Inject
    var countryAvailabilityService: GuardarianCountryAvailabilityService

    init() {
        availableMenuActionLoading = true
        Task { @MainActor in
            isExchangeButtonVisible = await countryAvailabilityService.verifyCountrySupport()
            availableMenuActionLoading = false
        }
    }

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
    
    var availableActions: [MenuViewAction] {
        MenuViewAction.allCases.filter { action in
            action != .openExchange || isExchangeButtonVisible
        }
    }
}
