//
//  AppModel.swift
//  TabletopkitVisionApp
//
//  Created by Macarena Peralta on 3/21/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
