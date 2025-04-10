import SwiftUI
import RealityKit
import _RealityKit_SwiftUI
import TabletopKit
import AVKit

struct GameImmersiveView: View {
    @State private var game: Game? = nil
    @State private var anchor: AnchorEntity? = nil
    
    @Environment(ViewController.self) var viewController

    var body: some View {
        ZStack {
            RealityView { content in

                // 1. Try loading a .mp4
                if let mp4URL = Bundle.main.url(forResource: viewController.immersiveSpaceId, withExtension: "mp4") {
                    // ✅ Render 360 Video
                    let player = AVPlayer(url: mp4URL)
                    let videoMaterial = VideoMaterial(avPlayer: player)
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [videoMaterial])
                    sphere.name = "videoSphere"
                    sphere.scale = [-1, 1, 1]  // invert for inside viewing
                    sphere.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])  // rotate 180°

                    content.add(sphere)
                    player.play()
                    print("🎬 Playing 360 video: \(viewController.immersiveSpaceId).mp4")
                    
                


                // 2. Else try loading an image texture named after immersiveSpaceId
                } else if let texture = try? await TextureResource(named: viewController.immersiveSpaceId) {
                    // ✅ Render image
                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(texture))
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [material])
                    sphere.name = "imageSphere"
                    sphere.scale = [-1, 1, 1]
                    // sphere.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0]) // 90°, if needed

                    content.add(sphere)
                    print("🖼️ Displaying image sphere: \(viewController.immersiveSpaceId)")

                } else {
                    // 3. Couldn’t load either a .mp4 or an image with this ID
                    print("❌ No matching .mp4 or image for: \(viewController.immersiveSpaceId)")
                }

            }
            // Force re-render if immersiveSpaceId changes
            .id(viewController.immersiveSpaceId)
        }
    }
}









