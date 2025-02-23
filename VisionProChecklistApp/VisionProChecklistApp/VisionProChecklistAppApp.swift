import SwiftUI

@main
struct VisionProChecklistAppApp: App {
    @State private var immersiveSpaceID: String = "LivingRoom_360" // Default immersive space ID
    @State private var immersionStyle: ImmersionStyle = .full
    

    var body: some Scene {
        WindowGroup {
            ContentView(immersiveSpaceID: $immersiveSpaceID) // Pass the binding to ContentView
                .frame(width: 612, height: 792)
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: immersiveSpaceID) {
         //struct with the RealityView
            ImmersiveView(immersiveSpaceID: $immersiveSpaceID)
         }.immersionStyle(selection: $immersionStyle, in: .full)
        }
    }
    
    private func getRoomName(from immersiveSpaceID: String) -> String {
        print("Selected immersiveSpaceID: \(immersiveSpaceID)") // Debugging line
        switch immersiveSpaceID {
        case "LivingRoom_360":
            return "Living Room"
        case "Kitchen_360":
            return "Kitchen"
        case "Bathroom_360":
            return "Bathroom"
        case "Bedroom_360":
            return "Bedroom"
        default:
            return "Unknown Room"
        }
    }

