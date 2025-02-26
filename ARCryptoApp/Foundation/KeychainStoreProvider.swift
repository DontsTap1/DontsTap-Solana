//
//  KeychainStoreProvider.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 25.01.2025.
//

import Foundation
import Security

enum KeychainStoreKeys: String {
    case userToken = "userToken"
    case user = "user"
}

protocol KeychainStoreProvider {
    func get<T: Codable>(for key: KeychainStoreKeys) -> T?
    @discardableResult
    func store<T: Codable>(_ value: T, for key: KeychainStoreKeys) -> Bool
    @discardableResult
    func delete(for key: KeychainStoreKeys) -> Bool

    func get<T: Codable>(with key: String) -> T?
    @discardableResult
    func store<T: Codable>(with value: T, for key: String) -> Bool
    @discardableResult
    func delete(with key: String) -> Bool
}

final class KeychainStore: KeychainStoreProvider {
    private let service = "com.steady.DontStap"

    @discardableResult
    func store<T: Codable>(_ value: T, for key: KeychainStoreKeys) -> Bool {
        store(with: value, for: key.rawValue)
    }

    @discardableResult
    func delete(for key: KeychainStoreKeys) -> Bool {
        delete(with: key.rawValue)
    }

    func get<T: Codable>(for key: KeychainStoreKeys) -> T? {
        get(with: key.rawValue)
    }

    // MARK: - Generic methods

    @discardableResult
    func store<T: Codable>(with value: T, for key: String) -> Bool {
        guard let data = try? JSONEncoder().encode(value) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete existing item if it exists

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    @discardableResult
    func delete(with key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    func get<T: Codable>(with key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
