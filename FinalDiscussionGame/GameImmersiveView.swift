import SwiftUI
import RealityKit
import _RealityKit_SwiftUI
import TabletopKit

struct GameImmersiveView: View {
    @State private var game: Game? = nil
    @State private var anchor: AnchorEntity? = nil
    @Binding var immersiveSpaceID: String

    var body: some View {
        ZStack {
            RealityView { content in
                if let texture = try? await TextureResource(named: immersiveSpaceID) {
                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(texture))
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [material])
                    sphere.scale = [-1, 1, 1]
                    content.add(sphere)
                }
            }
            .id(immersiveSpaceID)
        }
    }
//            if let loadedGame = game, let tableAnchor = anchor {
//                RealityView { content in
//                    content.add(tableAnchor)
//
//                    loadedGame.renderer.root.transform.translation = .zero
//                    tableAnchor.addChild(loadedGame.renderer.root)
//
//                    if let texture = try? await TextureResource(named: "360image") {
//                        var material = UnlitMaterial()
//                        material.color = .init(texture: .init(texture))
//                        let sphere = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [material])
//                        sphere.scale = [-1, 1, 1]
//                        loadedGame.renderer.root.addChild(sphere)
//                    }
//
//                    print("Game added to anchor.")
//                }
//                // Unwrapped game + anchor here
//                .tabletopGame(loadedGame.tabletopGame, parent: tableAnchor) { _ in
//                    GameInteraction(game: loadedGame)
//                }
//
//            } else {
//                // Load game + anchor
//                Color.clear
//                    .task {
//                        print("Loading game + anchor...")
//                        let newGame = await Game()
//                        game = newGame
//                        anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
//                        print("Game and anchor loaded.")
//                    }
//            }
        
    
}







