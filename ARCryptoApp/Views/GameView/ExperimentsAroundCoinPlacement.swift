//
//  ExperimentsAroundCoinPlacement.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 08.04.2025.
//

/// ignore this
/// 
/*
func spawnCoinsOnDetectedPlanes() {
        guard let arView = self.arView,
              !detectedPlaneAnchors.isEmpty else {
            return
        }

        // Clear previous coins

        coinEntities.forEach { $0.removeFromParent() }
        coinEntities.removeAll()

        // Choose the largest or most suitable plane
        let selectedPlane = detectedPlaneAnchors.max { $0.extent.x * $0.extent.z > $1.extent.x * $1.extent.z }
        guard let plane = selectedPlane else { return }

        let planeTransform = plane.transform
        let planeCenter = planeTransform.translation

        let coinCount = 10
        let anchor = AnchorEntity(world: planeCenter)

        for i in 0..<coinCount {
            guard let coin = coinAREntity?.clone(recursive: true) else {
                continue
            }

            // Circular distribution within plane bounds
            let angle = Float(i) * (2 * .pi / Float(coinCount))
            let maxExtent = min(plane.extent.x, plane.extent.z) / 2

            let radiusLowerBound: Float = 0.2
            let radiusUpperBound: Float = maxExtent > radiusLowerBound ? maxExtent : Float(0.3)
            let radius = Float.random(in: 0.2...(radiusUpperBound * 0.8))

            let xOffset = radius * cos(angle)
            let zOffset = radius * sin(angle)

            let position = SIMD3<Float>(
                planeCenter.x + xOffset,
                planeCenter.y + 0.05, // Slight lift above the plane
                planeCenter.z + zOffset
            )

            coin.position = position
            //              coin.name = "Coin_\(coinEntities.count)"

            // Enhance tappability
            coin.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .yellow, isMetallic: true)]
            coin.collision = CollisionComponent(
                shapes: [.generateBox(size: [0.1, 0.1, 0.1])],
                mode: .trigger,
                filter: .default
            )

            anchor.addChild(coin)
            coinEntities.append(coin)
            countRenderedCoins += 1
        }

        arView.scene.addAnchor(anchor)
    }
 */

    /*
    func spawnCoins() {
        guard let arView = arView else { return }

        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            print("### AR: ray cast gave results")
            let anchor = AnchorEntity(world: firstResult.worldTransform.translation)

            // More sophisticated coin distribution
            let coinCount = 10
            let basePosition = firstResult.worldTransform.translation
            let cameraTransform = arView.cameraTransform
            let cameraForward = -normalize(cameraTransform.matrix.columns.2.xyz)

            // Create a circular distribution pattern
            for i in 0..<coinCount {
                guard let coin = coinAREntity?.clone(recursive: true) else { continue }

                // Calculate position using polar coordinates for more natural spread
                let angle = Float(i) * (2 * .pi / Float(coinCount))
                let radius = Float.random(in: 0.4...0.8)

                // Create offset using polar to cartesian conversion
                let xOffset = radius * cos(angle)
                let zOffset = radius * sin(angle)

                // Add slight vertical variation
                let yOffset = Float.random(in: -0.1...0.1)

                // Position relative to base point and camera forward direction
                var position = basePosition
                + (cameraForward * Float.random(in: 0.3...0.6))  // Move forward from base point
                + SIMD3(xOffset, yOffset, zOffset)

                // Ensure position is visible and not obstructed
                guard isPositionVisible(position, arView: arView) else {
                    continue
                }

                coin.position = position
//                coin.name = "Coin_\(coinEntities.count)"

                // Add collision and interaction
                coin.components[ModelComponent.self]?.materials = [SimpleMaterial(color: .yellow, isMetallic: true)]
                coin.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])

                anchor.addChild(coin)
                coinEntities.append(coin)
                countRenderedCoins += 1
            }

            print("### AR: \(coinEntities.count) coins placed")
            arView.scene.addAnchor(anchor)
        }
    }
     */
