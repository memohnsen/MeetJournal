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
                        title: "What's the main focus?",
                        arrayOptions: liftOptions,
                        selected: $selectedLift
                    )
                    
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the intensity?",
                        arrayOptions: intensityOptions,
                        selected: $selectedIntensity
                    )
                    
                    TextFieldSection(
                        field: $checkInScore.goal,
                        title: "What's your goal for this session?",
                        colorScheme: colorScheme,
                        keyword: "goal"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How physically strong do you feel?",
                        value: $checkInScore.physicalStrength,
                        minString: "Weak",
                        maxString: "Strong",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How mentally strong do you feel?",
                        value: $checkInScore.mentalStrength,
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
                        title: "How confident do you feel?",
                        value: $checkInScore.confidence,
                        minString: "Not At All",
                        maxString: "Very",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate last night's sleep",
                        value: $checkInScore.sleep,
                        minString: "Poor",
                        maxString: "Great",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your energy",
                        value: $checkInScore.energy,
                        minString: "Low",
                        maxString: "High",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your stress",
                        value: $checkInScore.stress,
                        minString: "Extreme",
                        maxString: "Relaxed",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your soreness",
                        value: $checkInScore.soreness,
                        minString: "Extreme",
                        maxString: "None",
                        minValue: 1,
                        maxValue: 5
                    )
                    
                    Button {
                        Task {
                            await checkInViewModel.submitCheckIn(
                                checkInScore: checkInScore,
                                selectedLift: selectedLift,
                                selectedIntensity: selectedIntensity,
                                userId: clerk.user?.id ?? ""
                            )
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
