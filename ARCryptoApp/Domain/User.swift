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

    let id: String
    let email: String?
    let nickname: String?
    let coins: [Coin]
    let promocodes: [Promocode]
    let status: User.Status
    let authToken: String?
    let photoId: String?

    init(
        id: String,
        email: String? = nil,
        nickname: String? = nil,
        coins: [Coin],
        promocodes: [Promocode],
        status: User.Status,
        authToken: String? = nil,
        photoId: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.coins = coins
        self.promocodes = promocodes
        self.status = status
        self.authToken = authToken
        self.photoId = photoId
    }

    init(id: String) {
        self.id = id
        self.email = nil
        self.nickname = nil
        self.coins = []
        self.promocodes = []
        self.status = .guest
        self.authToken = nil
        self.photoId = nil
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
        self.photoId = try container.decodeIfPresent(String.self, forKey: .photoId)
    }
}
