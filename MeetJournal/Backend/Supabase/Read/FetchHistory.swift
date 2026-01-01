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
    var ouraDataCSV: String = ""
    
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
    
    // MARK: - Weekly CSV Methods (Past 7 Days)
    
    private func getDateSevenDaysAgo() -> String {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: sevenDaysAgo)
    }
    
    func fetchWeeklyCheckinsCSV(user_id: String) async -> String {
        let sevenDaysAgo = getDateSevenDaysAgo()
        
        do {
            let response = try await supabase
                .from("journal_daily_checkins")
                .select()
                .eq("user_id", value: user_id)
                .gte("check_in_date", value: sevenDaysAgo)
                .order("check_in_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                return csvString
            }
        } catch {
            print("Error fetching weekly check-ins CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        return ""
    }
    
    func fetchWeeklyCompReportsCSV(user_id: String) async -> String {
        let sevenDaysAgo = getDateSevenDaysAgo()
        
        do {
            let response = try await supabase
                .from("journal_comp_report")
                .select()
                .eq("user_id", value: user_id)
                .gte("meet_date", value: sevenDaysAgo)
                .order("meet_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                return csvString
            }
        } catch {
            print("Error fetching weekly comp reports CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        return ""
    }
    
    func fetchWeeklySessionReportCSV(user_id: String) async -> String {
        let sevenDaysAgo = getDateSevenDaysAgo()
        
        do {
            let response = try await supabase
                .from("journal_session_report")
                .select()
                .eq("user_id", value: user_id)
                .gte("session_date", value: sevenDaysAgo)
                .order("session_date", ascending: false)
                .csv()
                .execute()
            
            if let csvString = String(data: response.data, encoding: .utf8) {
                return csvString
            }
        } catch {
            print("Error fetching weekly session reports CSV: \(error.localizedDescription)")
            print("Full error: \(error)")
        }
        
        return ""
    }

    func fetchOuraDataCSV(userId: String, startDate: Date) async {
        ouraDataCSV = ""
        
        let ouraService = Oura()
        
        guard ouraService.getAccessToken(userId: userId) != nil else {
            print("User does not have Oura connected, skipping Oura data export")
            return
        }
        
        do {
            let sleepData = try await ouraService.fetchDailySleep(
                userId: userId,
                startDate: startDate,
                endDate: Date()
            )
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let filteredData = sleepData.filter { sleepRecord in
                if let recordDate = dateFormatter.date(from: sleepRecord.day) {
                    return recordDate >= startDate
                }
                return false
            }
            
            let sortedData = filteredData.sorted { first, second in
                guard let firstDate = dateFormatter.date(from: first.day),
                      let secondDate = dateFormatter.date(from: second.day) else {
                    return false
                }
                return firstDate < secondDate
            }
            
            var csvRows: [String] = []
            
            csvRows.append("day,sleep_duration_hours,hrv_ms,average_heart_rate_bpm,readiness_score")
            
            for record in sortedData {
                let sleepHours = record.sleepDurationHours.map { String(format: "%.2f", $0) } ?? ""
                let hrv = record.hrv.map { String(format: "%.1f", $0) } ?? ""
                let heartRate = record.averageHeartRate.map { String(format: "%.0f", $0) } ?? ""
                let readiness = record.readinessScore.map { String($0) } ?? ""
                
                let escapeCSV: (String) -> String = { value in
                    if value.isEmpty {
                        return ""
                    }
                    if value.contains(",") || value.contains("\"") {
                        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
                    }
                    return value
                }
                
                let row = [
                    record.day,
                    escapeCSV(sleepHours),
                    escapeCSV(hrv),
                    escapeCSV(heartRate),
                    escapeCSV(readiness)
                ].joined(separator: ",")
                
                csvRows.append(row)
            }
            
            ouraDataCSV = csvRows.joined(separator: "\n")
            
        } catch {
            print("Error fetching Oura data for CSV export: \(error.localizedDescription)")
            print("Full error: \(error)")
            ouraDataCSV = ""
        }
    }
}

