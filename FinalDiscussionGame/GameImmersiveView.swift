import SwiftUI
import RealityKit
import _RealityKit_SwiftUI
import TabletopKit

struct GameImmersiveView: View {
    @State private var game: Game? = nil
    @State private var anchor: AnchorEntity? = nil
    
    @Environment(ViewController.self) var viewController

    var body: some View {
        ZStack {
            RealityView { content in
                if let texture = try? await TextureResource(named: viewController.immersiveSpaceId) {
                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(texture))
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [material])
                    sphere.scale = [-1, 1, 1]
                    let angle = Float.pi / 2  // 90 degrees
                    sphere.transform.rotation = simd_quatf(angle: angle, axis: [0, 1, 0])

                    content.add(sphere)
                }
            }
            .id(viewController.immersiveSpaceId)
        }
    }
}







