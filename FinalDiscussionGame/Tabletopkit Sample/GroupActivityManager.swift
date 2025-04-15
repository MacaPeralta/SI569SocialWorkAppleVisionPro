/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Start and coordinate with GroupActivities sessions.
*/

import GroupActivities
import SwiftUI
@preconcurrency import TabletopKit

// Compiler indicates this is risky, but it's the easiest way to make shareplay work
extension GroupSession: @unchecked @retroactive Sendable {}

struct Activity: GroupActivity {
    static let activityIdentifier: String = "SocialSphere"
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "SocialSphere"
        return metadata
    }
}

@MainActor
class GroupActivityManager: ObservableObject {
    var tabletopGame: TabletopGame
    var viewController: ViewController
    var currentSession: GroupSession<Activity>?
    var currentSessionMessenger: GroupSessionMessenger?
    var sessionTask: Task<Void, Never>? = nil
    var tasks = Set<Task<Void, Never>>()
    
    init(tabletopGame: TabletopGame, viewController: ViewController) {
        self.tabletopGame = tabletopGame
        self.viewController = viewController
        startSessionObservation()
    }
    
    func startSessionObservation() {
        Task {
            for await session in Activity.sessions() {
                let messenger = GroupSessionMessenger(session: session)
                self.currentSessionMessenger = messenger
                tasks.insert(
                    Task {
                        for await (message, _) in messenger.messages(of: AppStateMessage.self) {
                            print("Received message: \(message)")
                            handleStateMessage(message)
                        }
                    }
                )
                
                sessionTask = Task {
                    await configureSession(session: session)
                    currentSession = session
                    tabletopGame.coordinateWithSession(session)
                }
                tasks.insert(sessionTask!)
            }
        }
    }
    
    deinit {
        tabletopGame.detachNetworkCoordinator()
        sessionTask?.cancel()
    }
    
    func configureSession(session: GroupSession<Activity>) async {
        // override default shareplay settings
        var configuration = SystemCoordinator.Configuration()
        //configuration.supportsGroupImmersiveSpace = true
        configuration.spatialTemplatePreference = .sideBySide
        await session.systemCoordinator?.configuration = configuration
    }
    
    func updateSpatialTemplatePreference(isGroupSession: Bool) async {
        guard let session = currentSession else {
            print("No active session to update.")
            return
        }
        
        var configuration = SystemCoordinator.Configuration()
        //configuration.supportsGroupImmersiveSpace = true
        configuration.spatialTemplatePreference = isGroupSession ? .surround : .custom(IndividualTemplate())
        await session.systemCoordinator?.configuration = configuration
    }
    
    func sendStateMessage(_ message: AppStateMessage) {
        Task {
            do {
                try await currentSessionMessenger?.send(message)
                print("\(message) send successfully")
            } catch {
                print("send message failed: \(error)")
            }
        }
    }
    
    func handleStateMessage(_ message: AppStateMessage) {
        Task{
            print("message received: \(message)")
            viewController.appState = message.appState
            viewController.appStateUpdated = true
        }
    }
}

