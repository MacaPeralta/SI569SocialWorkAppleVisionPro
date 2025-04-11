/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Setup of the scene and views for the app.
*/
import SwiftUI
import RealityKit
import _RealityKit_SwiftUI 
import TabletopKit
import QuickLook

// MARK: App entrypoint
@main
struct SampleApp: App {
    @State private var immersionStyle: ImmersionStyle = .full
    @State private var immersiveSpaceID: String = "360image"
    @State private var checklistWindowWidth: CGFloat = 675
    @State private var showNotesPanel: Bool = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State private var viewController = ViewController()

    var body: some SwiftUI.Scene {
        WindowGroup(id: "Volumetric") {
            GameView()
                .volumeBaseplateVisibility(.hidden)
                .environment(viewController)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1.5, depth: 1, in: .meters)
        
        WindowGroup(id: "CheckList") {
            ContentView(checklistWindowWidth: $checklistWindowWidth, showNotesPanel: $showNotesPanel)
                .frame(width: checklistWindowWidth, height: 950)
                .environment(viewController)
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: immersiveSpaceID) {
            GameImmersiveView()
                .environment(viewController)
        }
        .immersionStyle(selection: $immersionStyle, in: .full)
    }
}

@MainActor
struct GameView: View {
    @Environment(\.realityKitScene) private var scene
    @Environment(ViewController.self) var viewController

    var body: some View {
        ZStack {
            if let loadedGame = viewController.game, viewController.activityManager != nil {
                RealityView { (content: inout RealityViewContent) in
                    content.entities.append(loadedGame.renderer.root)
                } update: { content in
                    let scale: Float = viewController.shouldShowTable ? 1.0 : 0.0
                    loadedGame.renderer.root.scale = SIMD3<Float>(scale, scale, scale)
                }
                .toolbar() {
                    if (viewController.appState != .homeInspection) {
                        GameToolbar(
                            viewController: viewController)
                    }
                }.tabletopGame(loadedGame.tabletopGame, parent: loadedGame.renderer.root) { _ in
                    GameInteraction(game: loadedGame)
                }
            }
        }
        .task {
            viewController.game = await Game()
            viewController.activityManager = .init(tabletopGame: viewController.game!.tabletopGame)
            
            await viewController.game?.showMiniDeck()
        }
    }
}


struct GameToolbar: ToolbarContent {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismissWindow
    
    var viewController: ViewController
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomOrnament) {
            if (!viewController.playedIntroVideo) {
                Button("Watch Intro Video") {
                    _ = PreviewApplication.open(urls: [viewController.videoURl])
                }
                Spacer()
                Button("Done Watching") {
                    viewController.playedIntroVideo = true
                    viewController.appState = .setup
                }
            } else {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    viewController.game!.resetGame()
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
                        viewController.immersiveSpaceId = "LivingRoom_360"
                        openWindow(id: "CheckList")
                        viewController.appState = .homeInspection
                        print("Enter home inspection")
                        //await viewController.game?.setDeckMode(.full)
                        await viewController.game?.showNormalDeck()
                        // viewController.immersiveSpaceId = "360image"
                        // if viewController.isInLibrary {
                        //     await dismissImmersiveSpace()
                        // } else {
                        //     let _ = await openImmersiveSpace(id: viewController.immersiveSpaceId)
                        // }
                        // viewController.appState = .intro
                        
                        await viewController.updateSpatialTemplate()
                    }
                } label: {
                    Label("Immersive", systemImage: viewController.isInLibrary ? "vision.pro.fill" : "vision.pro")
                }
                
                Spacer()
                if viewController.isInLibrary{
                    Button {
                        Task {
                            viewController.immersiveSpaceId = "LivingRoom_360"
                            openWindow(id: "CheckList")
                            viewController.appState = .homeInspection
                            print("Enter home inspection")
                            await viewController.updateSpatialTemplate()
                        }
                    } label: {
                        Label("HomeInspection", systemImage: "house")
                    }
                }
            }
        }
    }
}
