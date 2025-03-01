//
//  CoinMultiplierViewModel.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 01.03.2025.
//

import Combine
import SwiftUI

class CoinMultiplierViewModel: ObservableObject {
    @Published var promocode: String = ""
    @Published var isSubmitEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorPresented: Bool = false
    @Published var error: UserRepresentableError = GenericErrors.generic
    @Published var successPresented = false
    var successText = "Congrats! Promocode applied successfully! You can now multiply found coins!"

    @Inject
    private var promocodeStoreProvider: PromocodeStoreProvider
    private var cancellables = Set<AnyCancellable>()

    func submitPromocode() {
        isLoading = true

        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            do {
                try await promocodeStoreProvider.submitPromocode(promocode)
                successPresented.toggle()
                isLoading = false
            } catch let error as PromocodeStoreProviderError {
                self.error = error
                errorPresented = true
                isLoading = false
            } catch {
                self.error = GenericErrors.generic
                errorPresented = true
                isLoading = false
            }
        }
    }

    func openShop() {
        if let url = URL(string: "https://www.stapshop.dontstap.com") {
            UIApplication.shared.open(url)
        }
    }
}
