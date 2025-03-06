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
                        .frame(width: 50, height: 50)
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

    func setupARSession(in view: ARView) {
        print("### AR: session did setup")

        self.arView = view

        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = [.horizontal]
        view.session.run(arConfig)
        view.environment.sceneUnderstanding.options.insert(.occlusion)

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = view.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.delegate = self
        coachingOverlay.activatesAutomatically = true
        view.addSubview(coachingOverlay)

        print("### AR: overlay did add")
    }

    #warning("Spawn coins if now coins rendered anymore")
    func spawnCoins() {
        guard let arView = arView else { return }

        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = AnchorEntity(world: firstResult.worldTransform.translation)
            print("### AR: ray cast gave results")

            for _ in 0..<10 {
                if let coin = CoinEntity.loadCoinSync() {
                    print("### AR: coin did load")

                    let xOffset = Float.random(in: -0.7...0.7)
                    let zOffset = Float.random(in: -0.7...0.7)

                    coin.position = SIMD3(xOffset, 0, zOffset)
                    anchor.addChild(coin)
                }
            }

            arView.scene.addAnchor(anchor)
            print("### AR: 10 coins on anchor were placed")
        }
    }

    func collectCoin() {
        coinStoreProvider.collectCoin(type: .normal)
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
                #warning("verify if coin collect blocks main thread")
                DispatchQueue.global(qos: .userInitiated).async {
                    self.arViewModel.collectCoin()
                }
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
