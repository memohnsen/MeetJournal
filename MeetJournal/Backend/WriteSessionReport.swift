//
//  WriteSessionReport.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

struct SessionReport: Codable {
    var user_id: Int
    var session_rpe: Int
    var movement_quality: Int
    var focus: Int
    var misses: String
    var cues: String
    var feeling: String
}

@MainActor @Observable
class SessionReportModel {
    var isLoading: Bool = false
    var error: Error?
    var alertTitle: String = ""
    var alertMessage: String = ""
    var alertShown: Bool = false
    
    func submitSessionReport(sessionReport: SessionReport) async {
        isLoading = true
        error = nil
    
        do {
            try await supabase
                .from("journal_session_report")
                .insert(sessionReport)
                .execute()
            
            alertTitle = "Success!"
            alertMessage = "You have submitted your session report, time to recover for the next day!"
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
