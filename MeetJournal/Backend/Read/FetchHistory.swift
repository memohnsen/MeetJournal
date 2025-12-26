//
//  FetchHistory.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

@MainActor @Observable
class HistoryModel {
    var isLoading: Bool = false
    var error: Error?
    var checkIns: [DailyCheckIn] = []
    var compReport: [CompReport] = []
    var sessionReport: [SessionReport] = []
    var comp: [CompReport] = []
    var session: [SessionReport] = []
    var checkin: [DailyCheckIn] = []
    
    func fetchCheckins(id: Int) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: id)
                .execute()
            
            let row = try JSONDecoder().decode([DailyCheckIn].self, from: response.data)
            
            self.checkIns.removeAll()
            self.checkIns = row
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
    
    func fetchCompReports(id: Int) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: id)
                .execute()
            
            let row = try JSONDecoder().decode([CompReport].self, from: response.data)
            
            self.compReport.removeAll()
            self.compReport = row
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
    
    func fetchSessionReport(id: Int) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: id)
                .execute()
            
            let row = try JSONDecoder().decode([SessionReport].self, from: response.data)
            
            self.sessionReport.removeAll()
            self.sessionReport = row
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
    
    func fetchCompDetails(id: Int, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: id)
                .eq("meet", value: title)
                .eq("meet_date", value: date)
                .execute()
            
            let row = try JSONDecoder().decode([CompReport].self, from: response.data)
            
            self.comp.removeAll()
            self.comp = row
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
    
    func fetchSessionDetails(id: Int, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: id)
                .eq("selected_lift", value: title)
                .eq("session_date", value: date)
                .execute()
            
            let row = try JSONDecoder().decode([SessionReport].self, from: response.data)
            
            self.session.removeAll()
            self.session = row
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
    
    func fetchCheckInDetails(id: Int, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: id)
                .eq("selected_lift", value: title)
                .eq("check_in_date", value: date)
                .execute()
            
            let row = try JSONDecoder().decode([DailyCheckIn].self, from: response.data)
            
            self.checkin.removeAll()
            self.checkin = row
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

