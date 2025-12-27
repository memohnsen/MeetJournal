//
//  WorkoutReflectionView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct WorkoutReflectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = SessionReportModel()
    
    @State private var userViewModel = UsersViewModel()
    var user: [Users] { userViewModel.users }
    
    @State private var sessionDate: Date = Date()
    @State private var sessionRPE: Int = 3
    @State private var movementQuality: Int = 3
    @State private var focus: Int = 3
    @State private var misses: String = "0"
    @State private var cues: String = ""
    @State private var feeling: String = "Good"
    
    @State private var selectedLift: String = "Snatch"
    @State private var selectedIntensity: String = "Moderate"
    
    let liftOptionsWL: [String] = [
        "Snatch", "Clean", "Jerk", "C & J", "Total", "Squats", "Accessories", "Other"
    ]
    
    let liftOptionsPL: [String] = [
        "Squat", "Bench", "Deadlift", "Total", "Accessories", "Other"
    ]
    
    let intensityOptions: [String] = ["Maxing Out", "Heavy", "Moderate", "Light"]
    
    let missQuantity: [String] = ["0", "1", "2", "3", "4", "5+"]
    let feelingType: [String] = ["Beat Up", "Not too bad", "Good", "Great", "Amazing"]
    
    var hasCompletedForm: Bool {
        if cues.isEmpty {
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
                    
                    
                    if user.first?.sport == "Olympic Weightlifting" {
                        MultipleChoiceSection(
                            colorScheme: colorScheme,
                            title: "What's the main focus?",
                            arrayOptions: liftOptionsWL,
                            selected: $selectedLift
                        )
                    } else {
                        MultipleChoiceSection(
                            colorScheme: colorScheme,
                            title: "What's the main focus?",
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
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "How is your body feeling?", arrayOptions: feelingType, selected: $feeling)
                    
                    Button {
                        let report: SessionReport = SessionReport(user_id: 1, session_date: sessionDate.formatted(.iso8601.year().month().day().dateSeparator(.dash)), session_rpe: sessionRPE, movement_quality: movementQuality, focus: focus, misses: misses, cues: cues, feeling: feeling, selected_lift: selectedLift, selected_intensity: selectedIntensity, created_at: iso8601String)
                        
                        Task {
                            await viewModel.submitSessionReport(sessionReport: report)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Submit Check-In")
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
            .task {
                await userViewModel.fetchUsers(id: 2)
            }
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
