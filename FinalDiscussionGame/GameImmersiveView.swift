import SwiftUI
import RealityKit
import _RealityKit_SwiftUI
import TabletopKit
import AVKit
import AVFoundation

class AudioManager: ObservableObject {
    var player: AVAudioPlayer?

    func playLoopingAudio(named name: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("❌ Could not find audio file: \(name).\(fileExtension)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // 🔁 loop forever
            player?.volume = 0.3
            player?.play()
            print("🔊 Playing looping audio: \(name).\(fileExtension)")
        } catch {
            print("❌ Failed to play audio: \(error)")
        }
    }

    func stop() {
        player?.stop()
    }
}

struct GameImmersiveView: View {
    @State private var game: Game? = nil
    @State private var anchor: AnchorEntity? = nil
    @StateObject private var audioManager = AudioManager()  // 👈 audio manager

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
                    sphere.scale = [-1, 1, 1]
                    sphere.transform.rotation = simd_quatf(angle: .pi / -2, axis: [0, 1, 0])

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

                    // ⬅️ Image-specific rotation
                    if viewController.immersiveSpaceId == "360image" || viewController.immersiveSpaceId == "360image_new" {
                        sphere.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                        audioManager.playLoopingAudio(named: "LibraryNoise")  // 🔊 Start audio
                    } else if viewController.immersiveSpaceId == "Kitchen_360" {
                        sphere.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                        audioManager.stop()

                    } else {
                        sphere.transform.rotation = simd_quatf(angle: .pi / -2, axis: [0, 1, 0])
                        audioManager.stop()

                    }

                    content.add(sphere)
                    print("🖼️ Displaying image sphere: \(viewController.immersiveSpaceId)")
                } else {
                    print("❌ No matching .mp4 or image for: \(viewController.immersiveSpaceId)")
                }

            }
            .id(viewController.immersiveSpaceId)
            .onDisappear {
                audioManager.stop()  // 🔇 Stop when leaving scene
            }
        }
    }
}









