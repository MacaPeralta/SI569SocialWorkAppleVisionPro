//
//  TemplateTestGroupActivity.swift
//  TemplateTest
//
//  Created by Jingle Chen on 3/17/25.
//

import Foundation
import GroupActivities
import UIKit

struct TemplateTestGroupActivity: GroupActivity {
    static var activityIdentifier: String { "TemplateTestGroupActivity" }
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Template Test"
        metadata.subtitle = "Let's play together!"
        metadata.type = .generic
        return metadata
    }
}
