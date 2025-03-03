//
//  CoinCollectStoreProvider.swift
//  ARCoinCollect
//
//  Created by Ivan Tkachenko on 22.05.2024.
//

import Foundation
import Combine

protocol CoinCollectStoreProvider: AnyObject {
    var cachedCoinsCount: Int? { get }

    func getCoins() -> AnyPublisher<[Coin], Never>
    func collectCoin(type: Coin.CoinType)
}

class CoinCollectStore: CoinCollectStoreProvider {
    private let userSession: UserSessionProvider

    var cachedCoinsCount: Int? {
        userSession.user?.coins.count
    }

    init(userSession: UserSessionProvider) {
        self.userSession = userSession
    }

    func getCoins() -> AnyPublisher<[Coin], Never> {
        return userSession.getCoins()
    }

    func collectCoin(type: Coin.CoinType) {
        print("### Coin Store: coin did collect")
        if let promocodeMultiplier = userSession.user?.promocodes.max(by: { $0.multiplier < $1.multiplier })?.multiplier, !userSession.isGuestUser {
            var newCoins = [Coin]()
            for _ in 0..<promocodeMultiplier {
                newCoins.append(Coin(id: UUID(), type: type, state: .collected))
            }
            print("### Coin Store: multiplied coin stored")
            self.userSession.addCoins(newCoins)
        }
        else {
            let newCoin = Coin(id: UUID(), type: type, state: .collected)
            print("### Coin Store: normal coin stored")
            userSession.addCoin(newCoin)
        }
    }
}
