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
    @State private var checklistWindowWidth: CGFloat = 700
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
                .frame(width: checklistWindowWidth, height: 975)
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
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismissWindow

    var body: some View {
        ZStack {
            if let loadedGame = viewController.game, viewController.activityManager != nil {
                RealityView { (content: inout RealityViewContent) in
                    content.entities.append(loadedGame.renderer.root)
                    viewController.setupIntroVideoPlayerEntity()
                    if let videoEntity = viewController.introVideoPlayerEntity {
                        if videoEntity.scene == nil {
                            content.entities.append(videoEntity)
                            print("Intro video added to scene")
                        }
                    }
                } update: { content in
                    let scale: Float = viewController.isInLibrary ? 1.0 : 0.0
                    loadedGame.renderer.root.scale = SIMD3<Float>(scale, scale, scale)
                    
                    if !viewController.playedIntroVideo {
                        if let videoEntity = viewController.introVideoPlayerEntity {
                            if viewController.appState == .instructorVideo {
                                if !videoEntity.isEnabled {
                                    videoEntity.isEnabled = true
                                    print("Video Entity Enabled")
                                }
                            } else if viewController.appState == .playingInstructorVideo {
                                if !videoEntity.isEnabled {
                                    videoEntity.isEnabled = true
                                    print("Video Entity Enabled")
                                }
//                                viewController.introVideoPlayer.seek(to: .zero)
                                viewController.introVideoPlayer.play()
                                print("Video Play Triggered")
                            } else if viewController.appState == .setup {
                                if videoEntity.isEnabled {
                                    videoEntity.isEnabled = false
                                    viewController.introVideoPlayer.pause()
                                    print("Video Entity Disabled, Player Paused")
                                }
                            }
                        }
                    } else {
                        viewController.introVideoPlayer.pause()
                        viewController.introVideoPlayerEntity?.removeFromParent()
                    }
                    
                    if viewController.appStateUpdated {
                        if viewController.appState == .intro {
                            Task {
                                await viewController.updateSpatialTemplate()
                                viewController.immersiveSpaceId = "360image"
                                let _ = await openImmersiveSpace(id: viewController.immersiveSpaceId)
                            }
                            viewController.appStateUpdated = false
                        } else if viewController.appState == .homeInspection {
                            Task {
                                viewController.immersiveSpaceId = "LivingRoom_360"
                                openWindow(id: "CheckList")
                                print("Enter home inspection")
                                await viewController.game?.showNormalDeck()
                                await viewController.updateSpatialTemplate()
                            }
                            viewController.appStateUpdated = false
                        } else if viewController.appState == .discussion {
                            Task {
                                viewController.immersiveSpaceId = "360image"
                                let _ = await openImmersiveSpace(id: viewController.immersiveSpaceId)
                                await viewController.updateSpatialTemplate()
                            }
                            viewController.appStateUpdated = false
                        }
                    }
                }
                .toolbar() {
                    if (viewController.appState != .homeInspection && viewController.appState != .discussion) {
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
            viewController.activityManager = .init(tabletopGame: viewController.game!.tabletopGame, viewController: viewController)
            
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
            switch viewController.appState {
            case .setup:
                Button("Start") {
                    Task {
                         _ = try! await Activity().activate()
                        viewController.appState = .instructorVideo
                        viewController.appStateUpdated = true
                        viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                    }
                }
            case .instructorVideo:
                Button("Play Intro") {
                    viewController.appState = .playingInstructorVideo
                    viewController.appStateUpdated = true
                    viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                }
            case .playingInstructorVideo:
                Button("Done Watching") {
                    viewController.appState = .finishedInstructorVideo
                    viewController.appStateUpdated = true
                    viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                }
            case .finishedInstructorVideo:
                Button("Enter Library") {
                    viewController.appState = .intro
                    viewController.appStateUpdated = true
                    viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                }
            case .intro, .discussion:
                Button("Home Inspection") {
                    viewController.appState = .homeInspection
                    viewController.appStateUpdated = true
                    viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                }
            case .discussion:
                Button("Home Inspection") {
                    viewController.appState = .homeInspection
                    viewController.appStateUpdated = true
                    viewController.activityManager?.sendStateMessage(AppStateMessage(appState: viewController.appState))
                }
            default:
                Text("Something went wrong with app state")
            }
        }
    }
}
