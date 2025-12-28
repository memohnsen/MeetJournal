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
    
    var checkInsCSV: String = ""
    var compReportCSV: String = ""
    var sessionReportCSV: String = ""
    
    func fetchCheckins(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: user_id)
                .order("check_in_date", ascending: false)
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
    
    func fetchCompReports(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: user_id)
                .order("meet_date", ascending: false)
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
    
    func fetchSessionReport(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: user_id)
                .order("session_date", ascending: false)
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
    
    func fetchCompDetails(user_id: String, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: user_id)
                .eq("meet", value: title)
                .eq("meet_date", value: date)
                .order("meet_date", ascending: false)
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
    
    func fetchSessionDetails(user_id: String, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: user_id)
                .eq("selected_lift", value: title)
                .eq("session_date", value: date)
                .order("session_date", ascending: false)
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
    
    func fetchCheckInDetails(user_id: String, title: String, date: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: user_id)
                .eq("selected_lift", value: title)
                .eq("check_in_date", value: date)
                .order("check_in_date", ascending: false)
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
    
    func fetchCheckinsCSV(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: user_id)
                .order("check_in_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                self.checkInsCSV = csvString
            }
        } catch {
            print("Error fetching CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchCompReportsCSV(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: user_id)
                .order("meet_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                self.compReportCSV = csvString
            }
        } catch {
            print("Error fetching CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchSessionReportCSV(user_id: String) async {
        isLoading = true
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: user_id)
                .order("session_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                self.sessionReportCSV = csvString
            }
        } catch {
            print("Error fetching CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        isLoading = false
    }
}

