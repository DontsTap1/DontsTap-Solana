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

            for _ in 0..<10 {
                var position: SIMD3<Float>
                var attempts = 0

                repeat {
                    let xOffset = Float.random(in: -0.7...0.7)
                    let zOffset = Float.random(in: 0.05...1.0)
                    let yOffset: Float = 0.1
                    position = SIMD3(xOffset, yOffset, zOffset)

                    attempts += 1
                    if attempts > 10 { break } // Avoid infinite loop
                } while !isPositionVisible(position, arView: arView) || placedPositions.contains(where: { simd_distance($0, position) < 0.3 })

                if let coin = coinAREntity?.clone(recursive: true) {
                    print("### AR: coin did load")
                    coin.position = position
                    anchor.addChild(coin)
                    placedPositions.append(position)
                }
            }

            print("### AR: 10 coins on anchor were placed")
            arView.scene.addAnchor(anchor)
        }
    }

    private func isPositionVisible(_ position: SIMD3<Float>, arView: ARView) -> Bool {
        let cameraTransform = arView.cameraTransform
        let raycast = arView.scene.raycast(origin: cameraTransform.translation, direction: normalize(position - cameraTransform.translation))

        for result in raycast {
            if result.distance < simd_distance(cameraTransform.translation, position) {
                return false // Something is blocking the view
            }
        }

        return true // Position is clear
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

        init(arViewModel: ARViewModel) {
            self.arViewModel = arViewModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            print("### AR: user did tap somewhere")

            guard let arView = gesture.view as? ARView else { return }

            let location = gesture.location(in: arView)
            if let entity = arView.entity(at: location), entity.isCoinEntity {
                entity.removeFromParent()
                print("### AR: enity \(entity.name) \(entity.id) was removed")
                self.arViewModel.collectCoin()
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
