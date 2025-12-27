//
//  WriteCheckIn.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

@MainActor @Observable
class CheckInViewModel {
    var isLoading: Bool = false
    var error: Error?
    
    func submitCheckIn(
        checkInScore: CheckInScore,
        selectedLift: String,
        selectedIntensity: String,
        userId: String
    ) async {
        isLoading = true
        error = nil
        
        let iso8601String = Date.now.formatted(.iso8601)
        
        let checkIn = DailyCheckIn(
            user_id: userId,
            check_in_date: checkInScore.checkInDate.formatted(.iso8601.year().month().day().dateSeparator(.dash)),
            selected_lift: selectedLift,
            selected_intensity: selectedIntensity,
            goal: checkInScore.goal,
            physical_strength: checkInScore.physicalStrength,
            mental_strength: checkInScore.mentalStrength,
            recovered: checkInScore.recovered,
            confidence: checkInScore.confidence,
            sleep: checkInScore.sleep,
            energy: checkInScore.energy,
            stress: checkInScore.stress,
            soreness: checkInScore.soreness,
            physical_score: checkInScore.physicalScore,
            mental_score: checkInScore.mentalScore,
            overall_score: checkInScore.overallScore,
            created_at: iso8601String
        )
        
        do {
            try await supabase
                .from("journal_daily_checkins")
                .insert(checkIn)
                .execute()
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

