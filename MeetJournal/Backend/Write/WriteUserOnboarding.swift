//
//  WriteUserOnboarding.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/27/25.
//

import Foundation
import Supabase

@MainActor @Observable
class UserOnboardingViewModel {
    var isLoading: Bool = false
    var error: Error?
    
    func submitUserProfile(user: Users) async {
        isLoading = true
        error = nil
                
        do {
            try await supabase
                .from("journal_users")
                .insert(user)
                .execute()
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
}
