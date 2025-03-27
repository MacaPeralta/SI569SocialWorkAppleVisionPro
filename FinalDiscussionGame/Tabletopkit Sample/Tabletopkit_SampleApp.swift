/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Setup of the scene and views for the app.
*/
import SwiftUI
import RealityKit
import _RealityKit_SwiftUI 
import TabletopKit




// MARK: App entrypoint


@main
struct SampleApp: App {
    @State private var immersionStyle: ImmersionStyle = .full
    @State private var immersiveSpaceID: String = "360image"
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some SwiftUI.Scene {
        WindowGroup(id: "Volumetric") {
            GameView(immersiveSpaceID: $immersiveSpaceID).volumeBaseplateVisibility(.hidden)
//                .task {
//                    await openImmersiveSpace(id: "ImmersiveGameSpace")
//                }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1.5, depth: 1, in: .meters)
        
        
        
        WindowGroup(id: "CheckList") {
            ContentView(immersiveSpaceID: $immersiveSpaceID)
            .frame(width: 612, height: 792)
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: immersiveSpaceID) {
            GameImmersiveView(immersiveSpaceID: $immersiveSpaceID)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}






@MainActor
struct GameView: View {
    @Environment(\.realityKitScene) private var scene
    @State private var game: Game?
    @State private var activityManager: GroupActivityManager?
    @Binding var immersiveSpaceID: String

    var body: some View {
        ZStack {
            if let loadedGame = game, activityManager != nil {
                RealityView { (content: inout RealityViewContent) in
                    content.entities.append(loadedGame.renderer.root)
                    content.add(loadedGame.renderer.portalWorld)
                    //content.add(loadedGame.renderer.portal)
                }.toolbar() {
                    GameToolbar(game: loadedGame, immersiveSpaceID: $immersiveSpaceID)
                }.tabletopGame(loadedGame.tabletopGame, parent: loadedGame.renderer.root) { _ in
                    GameInteraction(game: loadedGame)
                }
            }
        }
        .task {
            self.game = await Game()
            self.activityManager = .init(tabletopGame: game!.tabletopGame)
        }
    }
}


struct GameToolbar: ToolbarContent {
    @State private var showImmersiveLibView: Bool = false
    @State private var showImmersiveHomeInspecView: Bool = false
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismissWindow
    @Binding var immersiveSpaceID: String
    
    let game: Game
    init(game: Game, immersiveSpaceID: Binding<String>) {
        self.game = game
        _immersiveSpaceID = immersiveSpaceID
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomOrnament) {
            Button("Reset", systemImage: "arrow.counterclockwise") {
                game.resetGame()
            }
            Spacer()
            Button("SharePlay", systemImage: "shareplay") {
               Task {
                    try! await Activity().activate()
               }
            }
            Spacer()
                Button {
                    Task {
                        immersiveSpaceID = "360image"
                        if showImmersiveLibView {
                            await dismissImmersiveSpace()
                        } else {
                            let result = await openImmersiveSpace(id: immersiveSpaceID)
                        }
                        showImmersiveLibView.toggle() //true
                    }
                } label: {
                    Label("Immersive", systemImage: showImmersiveLibView && immersiveSpaceID == "360image" ? "vision.pro.fill" : "vision.pro")
                }
            
            Spacer()
            if showImmersiveLibView{
                Button {
                    Task {
                            immersiveSpaceID = "LivingRoom_360"
                            showImmersiveLibView.toggle() //false
                            showImmersiveHomeInspecView.toggle() //true
                            openWindow(id: "CheckList")
                    }
                } label: {
                    Label("HomeInspection", systemImage: immersiveSpaceID == "LivingRoom_360" ? "house.fill" : "house")
                }
            }
            
            
        }
    }
}
