//
//  SessionModel.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation

struct SessionReport: Codable, Hashable {
    var user_id: Int
    var session_date: String
    var session_rpe: Int
    var movement_quality: Int
    var focus: Int
    var misses: String
    var cues: String
    var feeling: String
    var selected_lift: String
    var selected_intensity: String
    var created_at: String
}
