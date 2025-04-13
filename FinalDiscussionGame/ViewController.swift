//
//  ViewController.swift
//  Tabletopkit Sample
//
//  Created by Jingle Chen on 4/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import Foundation
import Observation
import AVKit
import RealityKit

enum AppState: Codable {
    case setup // Join SharePlay Session
    case instructorVideo // Instructor intro video appear
    case playingInstructorVideo // Playing instructor intro video
    case finishedInstructorVideo 
    case intro // Enter social work library and start initial discussion
    case homeInspection // Home Inspection
    case discussion // Final Group Discussion
    
    func isInLibrary() -> Bool {
        switch self {
        case .intro, .discussion:
            return true
        default:
            return false
        }
    }
}

@Observable
class ViewController {
    var appState: AppState = .setup
    var immersiveSpaceId: String = "360image" // TODO: Change to enum
    var isInLibrary: Bool {
        appState.isInLibrary()
    }
    var playedIntroVideo: Bool {
        switch appState {
        case .setup, .instructorVideo, .playingInstructorVideo:
            return false
        default:
            return true
        }
    }
    var appStateUpdated = false
    
    let videoURl: URL = Bundle.main.url(forResource: "IntroVid", withExtension: "mov")!
    let introVideoPlayer = AVPlayer(
        url: Bundle.main.url(forResource: "IntroVid", withExtension: "mov")!
    )
    var introVideoPlayerEntity: ModelEntity? = nil
    
    
    var game: Game?
    var activityManager: GroupActivityManager?
    
    @MainActor
    func updateSpatialTemplate() async {
        guard let activityManager else { return }
        await activityManager.updateSpatialTemplatePreference(isGroupSession: appState != .homeInspection)
    }
    
    @MainActor
    func setupIntroVideoPlayerEntity() {
        if introVideoPlayerEntity == nil {
            let videoMaterial = VideoMaterial(avPlayer: introVideoPlayer)
            let videoEntity = ModelEntity(
                mesh: .generatePlane(width: 1, height: 9.0 / 16.0), // Correct aspect ratio
                materials: [videoMaterial]
            )
            videoEntity.position = [0, -0.4, 0.4]
            introVideoPlayerEntity = videoEntity
        }
    }
}
