//
//  FetchUsers.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

struct Users: Codable, Identifiable, Hashable {
    var id: Int
    var first_name: String
    var last_name: String
    var sport: String
    var years_of_experience: Int
    var meets_per_year: Int
    var goal: String
    var biggest_struggle: String
    var training_days: [String: String]
}

@MainActor @Observable
class UsersViewModel {
    var isLoading: Bool = false
    var error: Error?
    var users: [Users] = []
    
    func fetchUsers() async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_users")
                .select()
                .execute()
            
            let row = try JSONDecoder().decode([Users].self, from: response.data)
            
            self.users = row
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
