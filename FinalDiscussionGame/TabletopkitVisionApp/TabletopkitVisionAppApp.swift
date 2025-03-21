//
//  TabletopkitVisionAppApp.swift
//  TabletopkitVisionApp
//
//  Created by Macarena Peralta on 3/21/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

@main
struct TabletopkitVisionAppApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
