//
//  DeleteOne.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/29/25.
//

import Foundation
import Supabase

@MainActor @Observable
class DeleteOneModel {
    var isLoading: Bool = false
    var error: Error?
    
    func deleteCompReport(reportId: Int) async {
        isLoading = true
        error = nil
        
        do {
            try await supabase
                .from("journal_comp_report")
                .delete()
                .eq("id", value: reportId)
                .execute()
        } catch {
            self.error = error
            print("Error deleting comp report: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func deleteSessionReport(reportId: Int) async {
        isLoading = true
        error = nil
        
        do {
            try await supabase
                .from("journal_session_report")
                .delete()
                .eq("id", value: reportId)
                .execute()
        } catch {
            self.error = error
            print("Error deleting session report: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func deleteCheckIn(checkInId: Int) async {
        isLoading = true
        error = nil
        
        do {
            try await supabase
                .from("journal_daily_checkins")
                .delete()
                .eq("id", value: checkInId)
                .execute()
        } catch {
            self.error = error
            print("Error deleting check-in: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
