import SwiftUI
import RealityKit
import RealityKitContent
import RealityKitContent
import AVKit

struct ImmersiveView: View {
    @Binding var immersiveSpaceID: String
    
    var body: some View {
        RealityView() { content in
            
            guard let texture = try? TextureResource.load(named: immersiveSpaceID) else {
                fatalError("Texture not loaded!")
            }
            
            let rootEntity = Entity()
            
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            
            rootEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))
            
            rootEntity.scale = .init(x: 1, y: 1, z: -1)
            rootEntity.transform.translation += SIMD3<Float>(0.0, 10.0, 0.0)
            let angle = Angle.degrees(90)
            let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
            rootEntity.transform.rotation = rotation
            
            content.add(rootEntity)
            
           print("Scene updated with new texture: \(immersiveSpaceID)")
        }
        .id(immersiveSpaceID)  // Force the view to rebuild when immersiveSpaceID changes with this line of code
    }
    
    //CODE FOR VIDEO GENERATION
    //            if let scene1 = try? await Entity(
    //                named: "untitled", in: realityKitContentBundle)
    //            {
    ////                print("interviewButtonClicked: ", interviewButtonClicked)
    //                if let model1 = scene1.findEntity (named:"Cube") as? ModelEntity // look for object inside usdz file called cube (from blender entity)
    //                {
    //                    if var comps1 = model1.components[ModelComponent.self]
    //                    {
    //                        // Position the model - changing z and y position of curved screen to position it currently
    //                        model1.position.z = -3
    //                        model1.position.y = 2.5
    //
    //                        // this is the url of a traffic camera stream
    //                        let player1 = AVPlayer (url: URL(string:"https://publicstreamer2.cotrip.org/rtplive/036E03750CAM1RP1/playlist.m3u8")!)
    //                        // material is taking player and putting it on the object
    //                        let material1 = VideoMaterial(avPlayer: player1)
    //                        player1.play()
    //                        comps1.materials = [material1]
    //                        model1.components.set(comps1)
    //                        content.add(model1)
    //                    }
    //                }
    //
    //            }
}
