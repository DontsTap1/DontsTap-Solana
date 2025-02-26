//
//  Coin.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import Foundation

struct Coin: Codable {
    enum CoinType: Int, Codable {
        case normal = 0
        case multplied
    }

    enum CoinState: Int, Codable {
        case available = 0
        case collected
    }

    let id: UUID
    let type: CoinType
    let state: CoinState
}
