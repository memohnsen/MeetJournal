//
//  WriteCompReport.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Supabase
import Foundation

struct CompReport: Codable {
    var user_id: Int
    var meet: String
    var selected_meet_type: String
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
}

@MainActor @Observable
class CompReportModel {
    var isLoading: Bool = false
    var error: Error?
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertShown: Bool = false
    
    func submitCompReport(compReport: CompReport) async {
        isLoading = true
        error = nil

        do {
            try await supabase
                .from("journal_comp_report")
                .insert(compReport)
                .execute()
            
            alertTitle = "Success!"
            alertMessage = "You have submitted your competition report, time to recover and focus on the next one!"
        } catch {
            self.error = error
            print("Error submitting check-in: \(error.localizedDescription)")
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = error.localizedDescription
        }
        
        alertShown = true
        isLoading = false
    }
}
