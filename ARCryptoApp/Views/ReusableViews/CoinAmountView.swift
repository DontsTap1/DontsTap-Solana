//
//  CoinAmountView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 01.03.2025.
//

import SwiftUI

struct CoinAmountView: View {
    private var coinAmount: Int {
        coinProvider.cachedCoinsCount ?? .zero
    }

    @Inject
    private var coinProvider: CoinCollectStoreProvider

    var body: some View {
        VStack {
            Image("coinIcon")
                .resizable()
                .frame(width: 50, height: 50)

            Text("\(coinAmount)")
                .font(.title)
                .bold()
                .foregroundColor(.yellow)
        }
    }
}
