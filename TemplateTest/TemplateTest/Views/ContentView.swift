//
//  ContentView.swift
//  TemplateTest
//
//  Created by Jingle Chen on 3/17/25.
//  Referenced: https://medium.com/@xinyichen0321/visionos-shareplay-tutorial-all-you-need-to-know-026f897b8929
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities
import Combine

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
                
                // add an environment light to the volume
                guard let resource = try? await EnvironmentResource(named: "test") else { return }
                let iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 1)
                scene.components.set(iblComponent)
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = viewModel.isHomeInspection ? 0.0 : 0.9
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
            }
        }
        .task {
            viewModel.configureGroupSession()
        }
        .task {
            viewModel.registerGroupActivity()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack {
                    Button {
                        viewModel.toggleHomeInspection()
                    } label: {
                        Text(viewModel.isHomeInspection ? "Exit Home Inspection Mode" : "Enter Home Inspection Mode")
                    }
                    .fontWeight(.semibold)

                    ToggleImmersive()
                }
            }
        }
    }
}

struct ToggleImmersive: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var immersiveSpaceActive: Bool = false
    
    var body: some View {
        Button(immersiveSpaceActive ? "Exit SocialWork Library" : "View SocialWork Library") {
            Task {
                if !immersiveSpaceActive {
                    let result = await openImmersiveSpace(id: "Environment")
                    immersiveSpaceActive = true
                } else {
                    await dismissImmersiveSpace()
                    immersiveSpaceActive = false
                }
            }
        }
    }
}

// Logic
// TODO: Add Late Join Feature
class ContentViewModel: ObservableObject {
    @Published private(set) var isHomeInspection: Bool = false
    @Published private(set) var sharePlayEnabled: Bool = false
    @Published private var immersiveSpaceActive: Bool = false
    
    private var tasks = Set<Task<Void, Never>>()
    private var subscriptions: Set<AnyCancellable> = []
    private var sharePlayMessenger: GroupSessionMessenger?
    private var sharePlaySession: GroupSession<TemplateTestGroupActivity>?
    
    
    func toggleHomeInspection() {
        isHomeInspection.toggle()
        print("HomeInspectionMode: \(isHomeInspection)")
        updateSpatialTemplatePreference()
    }
    
    func updateSpatialTemplatePreference() {
        Task {
            if let systemCoordinator = await sharePlaySession?.systemCoordinator {
                print("update spatial template preference")
                var configuration = SystemCoordinator.Configuration()
                configuration.supportsGroupImmersiveSpace = true
                configuration.spatialTemplatePreference = isHomeInspection ? .custom(HomeInspectionTemplate()) : .surround
                systemCoordinator.configuration = configuration
            }
        }
    }
    
    func configureGroupSession() {
        Task {
            for await session in TemplateTestGroupActivity.sessions() {
                self.sharePlaySession = session
                
                //Override SharePay Default Settings
                if let systemCoordinator = await session.systemCoordinator {
                    var configuration = SystemCoordinator.Configuration()
                    configuration.supportsGroupImmersiveSpace = true
                    configuration.spatialTemplatePreference = .surround
                    systemCoordinator.configuration = configuration
                    
                    self.tasks.insert(
                        Task.detached { @MainActor in
                            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                                if let immersionStyle {
                                    // Open an Immersive space
                                } else {
                                    // Dismiss the immersive space
                                }
                            }
                        }
                    )
                    
                }
                
                // Retrieving & Initializing Group Session
                Task {
                    @MainActor in
                    sharePlayEnabled = true
                }
                
                session.join()
            }
        }
    }
    
    // Registering Group Activity
    func registerGroupActivity() {
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(TemplateTestGroupActivity())
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return Void.self }
            let metadata = TemplateTestGroupActivity().metadata
            return metadata
        }
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .activityItemsConfiguration = configuration
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(viewModel: ContentViewModel())
        .environment(AppModel())
}
