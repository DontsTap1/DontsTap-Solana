//
//  Promocode.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import Foundation

struct Promocode: Identifiable, Hashable, Codable {
    var id: UUID {
        UUID(uuidString: code) ?? UUID()
    }
    
    var code: String
    private(set) var isUsed: Bool = false
    var multiplier: Int

    func update(isUsed: Bool) -> Promocode {
        var copy = self
        copy.isUsed = isUsed
        return copy
    }
}
