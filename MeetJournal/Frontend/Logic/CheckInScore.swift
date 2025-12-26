//
//  CheckInScore.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import SwiftUI

@Observable
class CheckInScore {
    var checkInDate: Date = Date()
    var physicalStrength: Int = 3
    var mentalStrength: Int = 3
    var recovered: Int = 3
    var confidence: Int = 3
    var sleep: Int = 3
    var energy: Int = 3
    var stress: Int = 3
    var soreness: Int = 3
    var goal: String = ""
    
    var physicalScore: Int {
        let overall: Int = physicalStrength + recovered + energy + (5 - soreness)

        let maxScore = 20.0
        let percent = (Double(overall) / maxScore) * 100.0

        let percentScore = Int(max(0.0, min(100.0, percent)).rounded())
        return percentScore
    }
    
    var mentalScore: Int {
        let overall: Int = mentalStrength + confidence + sleep + stress

        let maxScore = 15.0
        let percent = (Double(overall) / maxScore) * 100.0

        let percentScore = Int(max(0.0, min(100.0, percent)).rounded())
        return percentScore
    }
    
    var overallScore: Int {
        let overall: Int = physicalStrength + recovered + energy + (5 - soreness) + mentalStrength + confidence + sleep + stress
        
        let maxScore = 35.0
        let percent = (Double(overall) / maxScore) * 100.0

        let percentScore = Int(max(0.0, min(100.0, percent)).rounded())
        return percentScore
    }
    
    var hasCompletedForm: Bool {
        if goal.isEmpty {
            return false
        }
        
        return true
    }
}
