import SwiftUI

@main
struct EnvironmentApp: App {
 //Select immersionStyle
 @State private var immersionStyle: ImmersionStyle = .full //For example you also can use .mixed for a mixed ImmersionStyle
 var body: some Scene {
 WindowGroup {
 //Starting Window to control entry in the ImmersiveSpace
     ContentView()
 }
 ImmersiveSpace(id: "Environment") {
 //struct with the RealityView
     EnvironmentRV()
 }.immersionStyle(selection: $immersionStyle, in: .full)

 }
}
