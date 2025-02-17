//
//  EnvironmentRV.swift
//  SocialWorkSphere
//
//  Created by Macarena Peralta on 2/15/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct EnvironmentRV: View {
 var body: some View {
 RealityView() { content in

 //load texture from xcassets
 guard let texture = try? TextureResource.load(named: "360image") else {fatalError("Texture not loaded!")}
 //create a entity
 let rootEntity = Entity()

 //create material for the texture 
 var material = UnlitMaterial() //Material without influence of lightning

 // add the texture (image) to the material
 material.color = .init(texture: .init(texture))
 
 //generate a sphere make it big so it fills out your whole vision in this example it has the size 1E3 (1* 10^3)
 //add the material to the entity
 rootEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))

 //adjust the properties of the entity size,angle, ...
 rootEntity.scale = .init(x: 1, y: 1, z: -1)
 rootEntity.transform.translation += SIMD3<Float>(0.0, 10.0, 0.0)
 let angle = Angle.degrees(90)
 let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
 rootEntity.transform.rotation = rotation


 //Add entity to RealityView
 content.add(rootEntity)

 } update: { content in
 //Here you can update the RealityKit content
 }


 }
} 

//
//  EnvironmentRV.swift
//  SocialWorkSphere
//
//  Created by Macarena Peralta on 2/15/25.
//

/*import SwiftUI
import RealityKit
import AVKit

struct EnvironmentRV: View {
    var body: some View {
        RealityView { content in
            let rootEntity = Entity()

            // Load the 360° video texture
            guard let videoMaterial = createVideoMaterial(videoName: "360Video") else {
                fatalError("Failed to create video material!")
            }

            // Create a sphere entity
            let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 1000), materials: [videoMaterial]) // Large sphere

            // Invert the sphere to make the video visible from the inside
            sphereEntity.scale = SIMD3<Float>(x: -1, y: 1, z: 1)

            // Add sphere to scene
            rootEntity.addChild(sphereEntity)
            content.add(rootEntity)
        }
    }
}

/// Function to create a video material for RealityKit
func createVideoMaterial(videoName: String) -> VideoMaterial? {
    // Load video from the app bundle
    guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
        print("⚠️ Video file not found!")
        return nil
    }

    // Create an AVPlayer for the video
    let player = AVPlayer(url: url)
    player.actionAtItemEnd = .none
    player.isMuted = false  // Set to true if you don't want sound
    player.play() // Start playing

    // Observe when the video ends and restart playback
    NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: player.currentItem,
        queue: .main
    ) { _ in
        player.seek(to: .zero)
        player.play()
    }

    // Create RealityKit VideoMaterial
    return VideoMaterial(avPlayer: player)
}

#Preview(windowStyle: .volumetric) {
    EnvironmentRV()
}*/

