//
//  WriteCheckIn.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

struct DailyCheckIn: Codable {
    var user_id: Int
    var selected_lift: String
    var selected_intensity: String
    var goal: String
    var physical_strength: Int
    var mental_strength: Int
    var recovered: Int
    var confidence: Int
    var sleep: Int
    var energy: Int
    var stress: Int
    var soreness: Int
    var physical_score: Int
    var mental_score: Int
    var overall_score: Int
}

@MainActor @Observable
class CheckInViewModel {
    var isLoading: Bool = false
    var error: Error?
    
    func submitCheckIn(
        checkInScore: CheckInScore,
        selectedLift: String,
        selectedIntensity: String,
        userId: Int = 1
    ) async {
        isLoading = true
        error = nil
        
        let checkIn = DailyCheckIn(
            user_id: userId,
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
            overall_score: checkInScore.overallScore
        )
        
        do {
            try await supabase
                .from("journal_daily_checkins")
                .insert(checkIn)
                .execute()
        } catch {
            self.error = error
            print("Error submitting check-in: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

