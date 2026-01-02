//
//  FetchObjectiveReviews.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/31/25.
//

import Foundation
import Supabase

@MainActor @Observable
class ObjectiveReviewViewModel {
    var isLoading: Bool = false
    var error: Error?
    var objectiveReviews: [ObjectiveReview] = []
    
    func fetchObjectiveReviews(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_objective_review")
                .select()
                .eq("user_id", value: user_id)
                .order("created_at", ascending: false)
                .execute()
            
            let row = try JSONDecoder().decode([ObjectiveReview].self, from: response.data)
            
            self.objectiveReviews.removeAll()
            self.objectiveReviews = row
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

