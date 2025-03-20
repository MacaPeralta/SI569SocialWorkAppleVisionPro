//
//  ImmersiveView.swift
//  TemplateTest
//
//  Created by Jingle Chen on 3/17/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView() { content in
            
            //load texture from xcassets
            guard let texture = try? TextureResource.load(named: "360image") else {fatalError("Texture not loaded!")}

            let skybox = Entity()
            var skyboxMat = UnlitMaterial()
            
            // add the texture (image) to the material
            skyboxMat.color = .init(texture: .init(texture))
            
            skybox.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [skyboxMat]))
            skybox.scale = .init(x: -1, y: 1, z: 1)
//            skybox.transform.translation -= SIMD3<Float>(0.0, 500.0, 0.0)
            let angle = Angle.degrees(90)
            let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
            skybox.transform.rotation = rotation
            
            
            
            let ground = Entity()

            let groundMat = UnlitMaterial(color: .gray)

            ground.components.set(ModelComponent(mesh: .generateCylinder(height: 0.5, radius: 1), materials: [groundMat]))
            
            //Add entity to RealityView
            content.add(skybox)
//            content.add(ground)
            
            
        } update: { content in
            //Here you can update the RealityKit content
            
        }
        
        
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
