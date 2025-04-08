//
//  GameView.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 12.01.2025.
//

import SwiftUI
import RealityKit
import ARKit

struct GameView: View {
    @Binding var showAR: Bool
    @StateObject private var viewModel = ARViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(arViewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Button(action: {
                    showAR.toggle()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.menuColors)
                        .clipShape(Circle())
                        .shadow(radius: 5.0)
                }
            }
        }
    }
}

// MARK: - AR View Container

class ARViewModel: NSObject, ObservableObject, ARCoachingOverlayViewDelegate {
    @Inject
    private var coinStoreProvider: CoinCollectStoreProvider
    private var arView: ARView?

    private var coinAREntity: CoinEntity?
    private var countRenderedCoins: Int = 0 {
        didSet {
            if isAllCoinsRemovedFromScene, countRenderedCoins == .zero {
                spawnCoins()
                isAllCoinsRemovedFromScene = false
            }
        }
    }
    private var isAllCoinsRemovedFromScene: Bool = false

    override init() {
        super.init()
        self.preLoadCoinEntity()
    }

    func setupARSession(in view: ARView) {
        print("### AR: session did setup")

        self.arView = view

        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = [.horizontal]
        view.session.run(arConfig)

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = view.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.delegate = self
        coachingOverlay.activatesAutomatically = true
        view.addSubview(coachingOverlay)

        print("### AR: overlay did add")
    }

    func spawnCoins() {
        guard let arView = arView else { return }

        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            print("### AR: ray cast gave results")
            let anchor = AnchorEntity(world: firstResult.worldTransform.translation)
            var placedPositions = [SIMD3<Float>]()

            // Get camera transform for coin placement
            let cameraTransform = arView.cameraTransform
            let cameraForward = -normalize(cameraTransform.matrix.columns.2.xyz)
            let cameraRight = normalize(cameraTransform.matrix.columns.0.xyz)

            // Define placement area in front of camera
            let minDistance: Float = 0.3
            let maxDistance: Float = 0.8
            let spreadAngle: Float = .pi / 4

            for _ in 0..<10 {
                var position: SIMD3<Float>
                var attempts = 0

                repeat {
                    // Calculate position in front of camera
                    let distance = Float.random(in: minDistance...maxDistance)
                    let angle = Float.random(in: -spreadAngle...spreadAngle)
                    
                    // Calculate position using camera's forward and right vectors
                    let forwardOffset = cameraForward * distance
                    let rightOffset = cameraRight * (distance * tan(angle))
                    
                    // Combine offsets with camera position
                    position = cameraTransform.translation + forwardOffset + rightOffset
                    position.y = firstResult.worldTransform.translation.y + 0.1 // Keep coins slightly above the plane

                    attempts += 1
                    if attempts > 10 { break } // Avoid infinite loop
                } while !isPositionVisible(position, arView: arView) || 
                        placedPositions.contains(where: { simd_distance($0, position) < 0.2 }) ||
                        simd_distance(position, cameraTransform.translation) < minDistance

                if let coin = coinAREntity?.clone(recursive: true) {
                    print("### AR: coin did load")
                    coin.position = position
                    anchor.addChild(coin)
                    placedPositions.append(position)
                    countRenderedCoins += 1
                }
            }

            print("### AR: 10 coins on anchor were placed")
            arView.scene.addAnchor(anchor)
        }
    }

    private func isPositionVisible(_ position: SIMD3<Float>, arView: ARView) -> Bool {
        let cameraTransform = arView.cameraTransform
        let cameraForward = -normalize(cameraTransform.matrix.columns.2.xyz)
        let directionToPosition = normalize(position - cameraTransform.translation)
        
        // Check if position is in front of camera (dot product > 0)
        let dotProduct = dot(cameraForward, directionToPosition)
        guard dotProduct > 0 else { return false }
        
        // Check if position is within field of view (angle < 45 degrees)
        let angle = acos(dotProduct)
        guard angle < .pi / 4 else { return false }
        
        // Check for obstacles
        let raycast = arView.scene.raycast(
            origin: cameraTransform.translation,
            direction: directionToPosition
        )
        
        return raycast.isEmpty || raycast.allSatisfy { result in
            result.distance >= simd_distance(cameraTransform.translation, position)
        }
    }

    private func preLoadCoinEntity() {
        coinAREntity = CoinEntity.loadCoinSync()
    }

    func collectCoin() {
        if countRenderedCoins - 1 == .zero {
            isAllCoinsRemovedFromScene = true
        }
        countRenderedCoins -= 1
        DispatchQueue.main.async { [weak self] in
            self?.coinStoreProvider.collectCoin(type: .normal)
        }
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        spawnCoins()
    }

    deinit {
        print("### AR: ARViewModel deinit")
    }
}

struct ARContainerView: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
#if targetEnvironment(simulator)
        arView.cameraMode = .nonAR
#endif

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        arView.session.delegate = context.coordinator
        arViewModel.setupARSession(in: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(arViewModel: arViewModel)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var arViewModel: ARViewModel
        private var lastTapTime: TimeInterval = 0
        private let tapCooldown: TimeInterval = 0.3 // Prevent rapid taps

        init(arViewModel: ARViewModel) {
            self.arViewModel = arViewModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let currentTime = Date().timeIntervalSince1970
            guard currentTime - lastTapTime >= tapCooldown else { return }
            lastTapTime = currentTime

            guard let arView = gesture.view as? ARView else { return }

            let location = gesture.location(in: arView)
            
            // Perform a more precise hit test
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let entity = arView.entity(at: location), entity.isCoinEntity {
                // Remove entity immediately for better responsiveness
                entity.removeFromParent()
                arViewModel.collectCoin()
            }
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARPlaneAnchor {
                    arViewModel.spawnCoins()
                }
            }
        }
    }
}

#Preview {
    GameView(showAR: .constant(false))
}

extension float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        return SIMD3(x, y, z)
    }
}
