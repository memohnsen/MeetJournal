//
//  CompModel.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation

struct CompReport: Codable, Hashable {
    var user_id: Int
    var meet: String
    var selected_meet_type: String
    var meet_date: String
    var performance_rating: Int
    var preparedness_rating: Int
    var did_well: String
    var needs_work: String
    var good_from_training: String
    var cues: String
    var focus: String
    var snatch1: String
    var snatch2: String
    var snatch3: String
    var cj1: String
    var cj2: String
    var cj3: String
    var snatch_best: Int
    var cj_best: Int
    var created_at: String
}
