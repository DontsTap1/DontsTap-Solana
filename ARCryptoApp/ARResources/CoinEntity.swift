//
//  CoinEntity.swift
//  ARCoinCollect
//
//  Created by Ivan Tkachenko on 16.03.2024.
//

import Combine
import Foundation
import RealityKit

final class CoinEntity: Entity, HasCollision {

    var model: Entity?

    /// Area of coin in 2D
    static let circleArea: Float = .pi * CoinEntity.radius * CoinEntity.radius
    static let radius: Float = 0.7

    fileprivate enum Constants {
        static let modelName = "ARCoin"
    }

    private(set) var revealed = true
    private(set) var isSpinning = true

    static func loadCoin() -> AnyPublisher<CoinEntity, Error> {
        return Future { promise in
            guard let arCoin = try? Entity.load(named: Constants.modelName) else {
                return promise(.failure(CoinEntityLoadError.failedToLoad))
            }

            let coinEntity = CoinEntity()
            coinEntity.name = Constants.modelName
            coinEntity.addChild(arCoin)

            return promise(.success(coinEntity))
        }
        .eraseToAnyPublisher()
    }

    static func loadCoinSync() -> CoinEntity? {
        guard let arCoin = try? Entity.load(named: Constants.modelName) else {
            return nil
        }

        let coinEntity = CoinEntity()
        coinEntity.name = Constants.modelName
        coinEntity.addChild(arCoin)

        // Get the actual bounding box size of the model
        let boundingBox = arCoin.visualBounds(relativeTo: nil)
        let collisionShape = ShapeResource.generateBox(size: boundingBox.extents * 1.5) // Make it bigger

        // Apply collision to the model, NOT the container entity
        arCoin.components.set(CollisionComponent(shapes: [collisionShape], mode: .trigger))

        return coinEntity
    }
}

extension Entity {
    var isCoinEntity: Bool {
        return name == CoinEntity.Constants.modelName
    }
}
