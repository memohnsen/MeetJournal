//
//  WriteCompReport.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Supabase
import Foundation

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
