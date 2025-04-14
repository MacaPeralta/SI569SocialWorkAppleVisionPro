//
//  ViewController.swift
//  Tabletopkit Sample
//
//  Created by Jingle Chen on 4/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import Foundation
import Observation

enum AppState {
    case setup // MR Stage to allow users to setup FaceTime
    case intro // Enter social work library and start initial discussion
    case instructorVideo // View instructor intro video
    case homeInspection // Home Inspection
    case discussion // Final Group Discussion
    
    func isInLibrary() -> Bool {
        switch self {
        case .homeInspection, .setup:
            return false
        default:
            return true
        }
    }
}

@Observable
class ViewController {
    var appState: AppState = .setup
    var immersiveSpaceId: String = "360image" // TODO: Change to enum
    var scene:String = "scene0"
    var isInLibrary: Bool {
        appState.isInLibrary()
    }
    var isHomeInspection: Bool {
        appState == .homeInspection ? true : false
    }
    var game: Game?
    var activityManager: GroupActivityManager?
    
    @MainActor
    func updateSpatialTemplate() async {
        guard let activityManager else { return }
        await activityManager.updateSpatialTemplatePreference(isGroupSession: !isHomeInspection)
    }
}
