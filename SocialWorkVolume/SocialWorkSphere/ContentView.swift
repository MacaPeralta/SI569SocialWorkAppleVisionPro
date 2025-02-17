import SwiftUI
import RealityKit

struct ContentView: View {

    //Environment Propery Wrapper for open a ImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    //Environment Propery Wrapper for closing a ImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    //Boolean to check if ImmersiveSpace is active
    @State private var immersiveSpaceActive: Bool = false
    var body: some View {
        //Button to control the immersiveSpace appearance
        Button(immersiveSpaceActive ? "Exit Environment" : "View Environment") {
            Task {
                if !immersiveSpaceActive {
                    let result = await openImmersiveSpace(id: "Environment")
                    immersiveSpaceActive = true
                } else {
                    await dismissImmersiveSpace()
                    immersiveSpaceActive = false
                }
            }
        }
    }
}
