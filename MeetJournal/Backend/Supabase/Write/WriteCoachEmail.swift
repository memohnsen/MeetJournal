//
//  WriteCoachEmail.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/30/25.
//

import Foundation
import Supabase

@MainActor @Observable
class CoachEmailManager {
    var isLoading: Bool = false
    var error: Error?

    func updateCoachEmail(userId: String, email: String?) async {
        isLoading = true
        error = nil
                
        do {
            try await supabase
                .from("journal_users")
                .update([
                    "coach_email": email
                ])
                .eq("user_id", value: userId)
                .execute()
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            self.error = error
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            self.error = error
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            self.error = error
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
            self.error = error
        } catch {
            print("Error updating coach email: \(error.localizedDescription)")
            print("Full error: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
}

