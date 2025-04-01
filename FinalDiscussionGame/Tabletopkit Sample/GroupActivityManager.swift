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
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic
        metadata.title = "TabletopKitSample"
        return metadata
    }
}

@MainActor
class GroupActivityManager: Observable {
    var tabletopGame: TabletopGame
    var sessionTask = Task<Void, Never> {}
    var sharePlaySession: GroupSession<Activity>?
    
    init(tabletopGame: TabletopGame) {
        self.tabletopGame = tabletopGame
        sessionTask = Task {
            for await session in Activity.sessions() {
                // override default shareplay settings
                var configuration = SystemCoordinator.Configuration()
                configuration.supportsGroupImmersiveSpace = true
                configuration.spatialTemplatePreference = .surround
                await session.systemCoordinator?.configuration = configuration
                tabletopGame.coordinateWithSession(session)
            }
        }
    }
    
    func updateSpatialTemplatePreference(showImmersiveLibSpace: Bool) {
        print("change template")
//        sessionTask.cancel()
        sessionTask = Task {
            for await session in Activity.sessions() {
                print("check")
                print("lib: \(showImmersiveLibSpace)")
                var configuration = SystemCoordinator.Configuration()
                configuration.supportsGroupImmersiveSpace = true
                configuration.spatialTemplatePreference = showImmersiveLibSpace ?  .surround : .custom(HomeInspectionTemplate())
                await session.systemCoordinator?.configuration = configuration
                tabletopGame.coordinateWithSession(session)
            }
        }
    }
    
    deinit {
        tabletopGame.detachNetworkCoordinator()
        sessionTask.cancel()
    }
}
