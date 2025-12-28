//
//  WriteSessionReport.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

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
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = context.debugDescription
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = context.debugDescription
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = context.debugDescription
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = context.debugDescription
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Full error: \(error)")
            
            alertTitle = "Error Submitting Your Report"
            alertMessage = error.localizedDescription
        }
        
        alertShown = true
        isLoading = false
    }
}
