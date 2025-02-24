import SwiftUI

@main
struct VisionProChecklistAppApp: App {
    @State private var immersiveSpaceID: String = "LivingRoom_360" // Default value of immersive space ID
    @State private var immersionStyle: ImmersionStyle = .full
    

    var body: some Scene {
        WindowGroup {
            ContentView(immersiveSpaceID: $immersiveSpaceID)
                .frame(width: 612, height: 792)
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: immersiveSpaceID) {
            ImmersiveView(immersiveSpaceID: $immersiveSpaceID)
         }.immersionStyle(selection: $immersionStyle, in: .full)
        }
    }
