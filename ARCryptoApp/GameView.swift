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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)

            // Close button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAR = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
#if targetEnvironment(simulator)
        arView.cameraMode = .nonAR
#endif

        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)

        // Add your AR content here
        let anchor = AnchorEntity(plane: .horizontal)
        // Example: Add a simple box
        let box = ModelEntity(mesh: .generateBox(size: 0.3))
        box.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}


#Preview {
    GameView(showAR: .constant(false))
}
