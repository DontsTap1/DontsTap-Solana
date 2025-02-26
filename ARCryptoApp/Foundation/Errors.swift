//
//  Errors.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import Foundation

enum GenericErrors: Error, UserRepresentableError {
    case generic

    var userErrorText: String {
        switch self {
        case .generic:
            return String.genericErrorText
        }
    }

    var userErrorDescription: String? {
        switch self {
        case .generic:
            return String.genericErrorDescription
        }
    }


}

enum CoinEntityLoadError: Error, UserRepresentableError {
    case failedToLoad

    var userErrorText: String {
        switch self {
        case .failedToLoad:
            return "Failed to load coin"
        }
    }

    var userErrorDescription: String? {
        nil
    }
}

protocol UserRepresentableError: Error {
    var userErrorText: String { get }
    var userErrorDescription: String? { get }
}

extension String {
    static var genericErrorText = "Something went wrong"
    static var genericErrorDescription = "Try again later."
}
