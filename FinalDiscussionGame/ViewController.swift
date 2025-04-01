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
    var appState: AppState = .intro
    var immersiveSpaceId: String = "360image"
    var game: Game?
    var activity: Activity?
}
