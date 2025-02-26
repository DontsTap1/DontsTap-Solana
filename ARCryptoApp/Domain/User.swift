//
//  User.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import Foundation

struct User: Identifiable, Codable {
    enum Status: Codable {
        case guest
        case signedIn
    }

    var id: String
    var email: String?
    var nickname: String?
    var coins: [Coin] = []
    var promocodes: [Promocode] = []
    var status: User.Status
    var authToken: String?

    init(
        id: String,
        email: String? = nil,
        nickname: String? = nil,
        coins: [Coin],
        promocodes: [Promocode],
        status: User.Status,
        authToken: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.coins = coins
        self.promocodes = promocodes
        self.status = status
        self.authToken = authToken
    }

    init(id: String) {
        self.id = id
        self.email = nil
        self.nickname = nil
        self.coins = []
        self.promocodes = []
        self.status = .guest
        self.authToken = nil
    }
}
