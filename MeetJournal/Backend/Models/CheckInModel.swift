//
//  CheckInModel.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation

struct DailyCheckIn: Codable, Hashable {
    var user_id: Int
    var selected_lift: String
    var selected_intensity: String
    var goal: String
    var physical_strength: Int
    var mental_strength: Int
    var recovered: Int
    var confidence: Int
    var sleep: Int
    var energy: Int
    var stress: Int
    var soreness: Int
    var physical_score: Int
    var mental_score: Int
    var overall_score: Int
    var created_at: String
}
