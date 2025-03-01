//
//  User.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import Foundation

struct User: Identifiable, Codable {
    enum Status: String, Codable {
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

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.status = try container.decode(User.Status.self, forKey: .status)

        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.coins = try container.decodeIfPresent([Coin].self, forKey: .coins) ?? []
        self.promocodes = try container.decodeIfPresent([Promocode].self, forKey: .promocodes) ?? []
        self.authToken = try container.decodeIfPresent(String.self, forKey: .authToken)
    }
}
