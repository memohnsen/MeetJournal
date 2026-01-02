//
//  WriteObjectiveReview.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/31/25.
//

import Foundation
import Supabase

@MainActor @Observable
class ObjectiveReviewModel {
    var isLoading: Bool = false
    var error: Error?
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertShown: Bool = false
    
    func submitObjectiveReview(objectiveReview: ObjectiveReview) async {
        isLoading = true
        error = nil
    
        do {
            try await supabase
                .from("journal_objective_review")
                .insert(objectiveReview)
                .execute()
            
            alertTitle = "Success!"
            alertMessage = "Your training cues have been saved!"
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Saving Your Cues"
            alertMessage = context.debugDescription
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Saving Your Cues"
            alertMessage = context.debugDescription
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Saving Your Cues"
            alertMessage = context.debugDescription
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Saving Your Cues"
            alertMessage = context.debugDescription
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
            
            alertTitle = "Error Saving Your Cues"
            alertMessage = error.localizedDescription
        }
        
        alertShown = true
        isLoading = false
    }
}

