//
//  WorkoutReflectionView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

struct WorkoutReflectionView: View {
    @AppStorage("userSport") private var userSport: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.clerk) private var clerk
    @State private var viewModel = SessionReportModel()
    
    @State private var sessionDate: Date = Date()
    @State private var timeOfDay: String = ""
    @State private var sessionRPE: Int = 3
    @State private var movementQuality: Int = 3
    @State private var focus: Int = 3
    @State private var misses: String = ""
    @State private var cues: String = ""
    @State private var feeling: Int = 3
    
    @State private var selectedLift: String = ""
    @State private var selectedIntensity: String = ""
    
    let liftOptionsWL: [String] = [
        "Snatch", "Clean", "Jerk", "C & J", "Total", "Squats", "Accessories", "Other"
    ]
    
    let liftOptionsPL: [String] = [
        "Squat", "Bench", "Deadlift", "Total", "Accessories", "Other"
    ]
    
    let timesOfDay: [String] = ["Early Morning", "Late Morning", "Afternoon", "Evening", "Night"]
    
    let intensityOptions: [String] = ["Maxing Out", "Heavy", "Moderate", "Light"]
    
    let missQuantity: [String] = ["0", "1", "2", "3", "4", "5+"]
    
    var hasCompletedForm: Bool {
        if cues.isEmpty || timeOfDay.isEmpty || misses.isEmpty || selectedLift.isEmpty || selectedIntensity.isEmpty {
            return false
        }
        
        return true
    }
    
    let iso8601String = Date.now.formatted(.iso8601)
    
    var body: some View {
        NavigationStack {
            ZStack{
                BackgroundColor()
                
                ScrollView {
                    DatePickerSection(title: "Session Date:", selectedDate: $sessionDate)
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "What time of day did you train?", arrayOptions: timesOfDay, selected: $timeOfDay)
                    
                    if userSport == "Olympic Weightlifting" {
                        MultipleChoiceSection(
                            colorScheme: colorScheme,
                            title: "What was the main focus?",
                            arrayOptions: liftOptionsWL,
                            selected: $selectedLift
                        )
                    } else {
                        MultipleChoiceSection(
                            colorScheme: colorScheme,
                            title: "What was the main focus?",
                            arrayOptions: liftOptionsPL,
                            selected: $selectedLift
                        )
                    }
                    
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the intensity?",
                        arrayOptions: intensityOptions,
                        selected: $selectedIntensity
                    )
                    
                    SliderSection(colorScheme: colorScheme, title: "How hard was this session?", value: $sessionRPE, minString: "Easy", maxString: "Almost Died", minValue: 1, maxValue: 5)
                    
                    SliderSection(colorScheme: colorScheme, title: "How was your movement quality?", value: $movementQuality, minString: "Poor", maxString: "Excellent", minValue: 1, maxValue: 5)
                    
                    SliderSection(colorScheme: colorScheme, title: "How was your focus?", value: $focus, minString: "Distracted", maxString: "Locked In", minValue: 1, maxValue: 5)
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "How many lifts did you miss?", arrayOptions: missQuantity, selected: $misses)
                    
                    TextFieldSection(field: $cues, title: "What cues made a difference?", colorScheme: colorScheme, keyword: "cues")
                    
                    SliderSection(colorScheme: colorScheme, title: "How is your body feeling?", value: $feeling, minString: "Beat Up", maxString: "Amazing", minValue: 1, maxValue: 5)
                    
                    Button {
                        let report: SessionReport = SessionReport(user_id: clerk.user?.id ?? "", session_date: sessionDate.formatted(.iso8601.year().month().day().dateSeparator(.dash)), timeOfDay: timeOfDay, session_rpe: sessionRPE, movement_quality: movementQuality, focus: focus, misses: misses, cues: cues, feeling: feeling, selected_lift: selectedLift, selected_intensity: selectedIntensity, created_at: iso8601String)
                        
                        Task {
                            await viewModel.submitSessionReport(sessionReport: report)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Submit Session Review")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(hasCompletedForm ? blueEnergy : .gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!hasCompletedForm)
                }
            }
            .navigationTitle("Session Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .alert(viewModel.alertTitle, isPresented: $viewModel.alertShown) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    WorkoutReflectionView()
}
