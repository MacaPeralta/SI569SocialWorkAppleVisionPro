//
//  TemplateTestApp.swift
//  TemplateTest
//
//  Created by Jingle Chen on 3/17/25.
//

import SwiftUI

@main
struct TemplateTestApp: App {

    @State private var appModel = AppModel()
    
    @StateObject private var contentViewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 0.2, depth: 1, in: .meters)

        ImmersiveSpace(id: "Environment") {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
