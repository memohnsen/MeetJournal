//
//  CheckInView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

struct CheckInView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.clerk) private var clerk

    @Bindable var checkInScore: CheckInScore
    @State private var selectedLift: String = "Snatch"
    @State private var selectedIntensity: String = "Moderate"
    @State private var checkInViewModel = CheckInViewModel()
    @State private var navigateToConfirmation: Bool = false
    
    let liftOptions: [String] = [
        "Snatch", "Clean", "Jerk", "C & J", "Total", "Squats", "Accessories", "Other"
    ]
    
    let intensityOptions: [String] = ["Maxing Out", "Heavy", "Moderate", "Light"]
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
            
                ScrollView{
                    DatePickerSection(title: "Session date:", selectedDate: $checkInScore.checkInDate)
                    
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the main movement for the session?",
                        arrayOptions: liftOptions,
                        selected: $selectedLift
                    )
                    
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the intensity for the session?",
                        arrayOptions: intensityOptions,
                        selected: $selectedIntensity
                    )
                    
                    TextFieldSection(
                        field: $checkInScore.goal,
                        title: "What would make today feel like a successful session for you?",
                        colorScheme: colorScheme,
                        keyword: "goal"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How strong does your body feel?",
                        value: $checkInScore.physicalStrength,
                        minString: "Weak",
                        maxString: "Strong",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How recovered do you feel?",
                        value: $checkInScore.recovered,
                        minString: "Not At All",
                        maxString: "Very",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How energized do you feel?",
                        value: $checkInScore.energy,
                        minString: "Low",
                        maxString: "High",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How sore does your body feel?",
                        value: $checkInScore.soreness,
                        minString: "None",
                        maxString: "Extreme",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How connected do you feel to your body?",
                        value: $checkInScore.bodyConnection,
                        minString: "Disconnected",
                        maxString: "Very Connected",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How strong does your mind feel?",
                        value: $checkInScore.mentalStrength,
                        minString: "Weak",
                        maxString: "Strong",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How confident do you feel?",
                        value: $checkInScore.confidence,
                        minString: "Not At All",
                        maxString: "Very",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How focused do you feel?",
                        value: $checkInScore.focus,
                        minString: "Distracted",
                        maxString: "Very Focused",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How stressed do you feel?",
                        value: $checkInScore.stress,
                        minString: "Extreme",
                        maxString: "Relaxed",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How ready do you feel to train?",
                        value: $checkInScore.readiness,
                        minString: "Not Ready",
                        maxString: "Very Ready",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How excited do you feel about today's session?",
                        value: $checkInScore.excitement,
                        minString: "Not Excited",
                        maxString: "Very Excited",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate last night's sleep quality",
                        value: $checkInScore.sleep,
                        minString: "Poor",
                        maxString: "Great",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    TextFieldSection(
                        field: $checkInScore.concerns,
                        title: "What concerns or worries do you have going into today's session?",
                        colorScheme: colorScheme,
                        keyword: "concerns"
                    )
                    
                    Button {
                        Task {
                            await checkInViewModel.submitCheckIn(
                                checkInScore: checkInScore,
                                selectedLift: selectedLift,
                                selectedIntensity: selectedIntensity,
                                userId: clerk.user?.id ?? ""
                            )
                            
                            AnalyticsManager.shared.trackCheckInSubmitted(lift: selectedLift, intensity: selectedIntensity, overallScore: checkInScore.overallScore)
                            navigateToConfirmation = true
                        }
                    } label: {
                        if checkInViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack{
                                Text("Submit Check-In")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(checkInScore.hasCompletedForm ? blueEnergy : .gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!checkInScore.hasCompletedForm || checkInViewModel.isLoading)
                }
            }
            .navigationDestination(isPresented: $navigateToConfirmation) {
                CheckinConfirmation(checkInScore: checkInScore, selectedLift: $selectedLift, selectedIntensity: $selectedIntensity)
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                AnalyticsManager.shared.trackScreenView("CheckInView")
            }
        }
    }
}

#Preview {
    struct CheckInView_PreviewContainer: View {
        @State private var checkInScore = CheckInScore()
        
        var body: some View {
            CheckInView(checkInScore: checkInScore)
        }
    }
    
    return CheckInView_PreviewContainer()
}
