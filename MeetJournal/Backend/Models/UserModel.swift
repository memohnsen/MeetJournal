//
//  UserModel.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation

struct Users: Codable, Identifiable, Hashable {
    var id: Int?
    var user_id: String
    var first_name: String
    var last_name: String
    var sport: String
    var years_of_experience: Int
    var meets_per_year: Int
    var goal: String
    var biggest_struggle: String
    var training_days: [String: String]
    var next_competition: String
    var next_competition_date: String
}
