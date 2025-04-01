/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Start and coordinate with GroupActivities sessions.
*/

//Old Code
//import GroupActivities
//import SwiftUI
//@preconcurrency import TabletopKit
//
//extension GroupSession: @unchecked @retroactive Sendable {}
//
//struct Activity: GroupActivity {
//    var metadata: GroupActivityMetadata {
//        var metadata = GroupActivityMetadata()
//        metadata.type = .generic
//        metadata.title = "TabletopKitSample"
//        return metadata
//    }
//}
//
//@MainActor
//class GroupActivityManager: Observable {
//    var tabletopGame: TabletopGame
//    var sessionTask = Task<Void, Never> {}
//    
//    init(tabletopGame: TabletopGame) {
//        self.tabletopGame = tabletopGame
//        sessionTask = Task {
//            for await session in Activity.sessions() {
//                // override default shareplay settings
//                var configuration = SystemCoordinator.Configuration()
//                configuration.supportsGroupImmersiveSpace = true
//                configuration.spatialTemplatePreference = .surround
//                await session.systemCoordinator?.configuration = configuration
//                tabletopGame.coordinateWithSession(session)
//            }
//        }
//    }
//    
//    deinit {
//        tabletopGame.detachNetworkCoordinator()
//        sessionTask.cancel()
//    }
//}

import GroupActivities
import SwiftUI
@preconcurrency import TabletopKit

// Compiler indicates this is risky, but it's the easiest way to make shareplay work
extension GroupSession: @unchecked @retroactive Sendable {}

struct Activity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "TabletopKitSample"
        return metadata
    }
}

@MainActor
class GroupActivityManager: ObservableObject {
    var tabletopGame: TabletopGame
    var sessionTask: Task<Void, Never>? = nil
    @Published var currentSession: GroupSession<Activity>?
    
    init(tabletopGame: TabletopGame) {
        self.tabletopGame = tabletopGame
        startSessionObservation()
    }
    
    func startSessionObservation() {
        sessionTask = Task {
            for await session in Activity.sessions() {
                await configureSession(session: session)
                tabletopGame.coordinateWithSession(session)
                self.currentSession = session
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
        configuration.supportsGroupImmersiveSpace = true
        configuration.spatialTemplatePreference = .surround
        await session.systemCoordinator?.configuration = configuration
    }
    
    func updateSpatialTemplatePreference(isGroupSession: Bool) async {
        guard let session = currentSession else {
            print("No active session to update.")
            return
        }
        
        var configuration = SystemCoordinator.Configuration()
        configuration.supportsGroupImmersiveSpace = true
        configuration.spatialTemplatePreference = isGroupSession ? .surround : .custom(IndividualTemplate())
        await session.systemCoordinator?.configuration = configuration
    }
}

