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
                let sphere = ModelEntity(mesh: .generateSphere(radius: 1000))
                sphere.scale = [-1, 1, 1]
                viewController.skySphereEntity = sphere
                viewController.skySphereEntity?.model?.materials = []
                content.add(sphere)
                
            } update: { content in
                guard let sphere = viewController.skySphereEntity else { return }
                guard let material = viewController.skySphereMaterial else { return }
                
                sphere.model?.materials = [UnlitMaterial(color: .darkGray)]
                
//                if viewController.immersiveSpaceId == "360image" {
//                    sphere.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
//                    audioManager.playLoopingAudio(named: "LibraryNoise")  // 🔊 Start audio
//                } else if viewController.immersiveSpaceId == "Kitchen_360" {
//                    sphere.transform.rotation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
//                    audioManager.stop()
//                } else {
//                    sphere.transform.rotation = simd_quatf(angle: .pi / -2, axis: [0, 1, 0])
//                    audioManager.stop()
//                }
                
                sphere.model?.materials = [material]
            }
            //.id(viewController.immersiveSpaceId)
            .onDisappear {
                audioManager.stop()  // 🔇 Stop when leaving scene
            }
        }
    }
}









