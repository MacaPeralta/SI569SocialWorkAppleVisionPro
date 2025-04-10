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
    case instructorVideo // View instructor intro video
    case setup // Join SharePlay Session
    case intro // Enter social work library and start initial discussion
    case homeInspection // Home Inspection
    case discussion // Final Group Discussion
    
    func isInLibrary() -> Bool {
        switch self {
        case .instructorVideo, .homeInspection, .setup:
            return false
        default:
            return true
        }
    }
}

@Observable
class ViewController {
    var appState: AppState = .instructorVideo
    var immersiveSpaceId: String = "360image" // TODO: Change to enum
    var isInLibrary: Bool {
        appState.isInLibrary()
    }
    var shouldShowTable: Bool {
        switch appState {
        case .instructorVideo, .homeInspection:
            return false
        default:
            return true
        }
    }
    
    let videoURl: URL = Bundle.main.url(forResource: "SampleVideo", withExtension: "MOV")!
    var playedIntroVideo = false
    
    var game: Game?
    var activityManager: GroupActivityManager?
    
    @MainActor
    func updateSpatialTemplate() async {
        guard let activityManager else { return }
        await activityManager.updateSpatialTemplatePreference(isGroupSession: appState != .homeInspection)
    }
}
