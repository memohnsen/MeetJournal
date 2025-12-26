//
//  WorkoutReflectionView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct WorkoutReflectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel = SessionReportModel()
    
    @State private var sessionRPE: Int = 3
    @State private var movementQuality: Int = 3
    @State private var focus: Int = 3
    @State private var misses: String = "0"
    @State private var cues: String = ""
    @State private var feeling: String = "Good"
    
    let missQuantity: [String] = ["0", "1", "2", "3", "4", "5+"]
    let feelingType: [String] = ["Beat Up", "Not too bad", "Good", "Great", "Amazing"]
    
    var hasCompletedForm: Bool {
        if cues.isEmpty {
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                BackgroundColor()
                
                ScrollView {
                    SliderSection(colorScheme: colorScheme, title: "How hard was this session?", value: $sessionRPE, minString: "Easy", maxString: "Almost Died")
                    
                    SliderSection(colorScheme: colorScheme, title: "How was your movement quality?", value: $movementQuality, minString: "Poor", maxString: "Excellent")
                    
                    SliderSection(colorScheme: colorScheme, title: "How was your focus?", value: $focus, minString: "Distracted", maxString: "Locked In")
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "How many lifts did you miss?", arrayOptions: missQuantity, selected: $misses)
                    
                    TextFieldSection(field: $cues, title: "What cues made a difference?", colorScheme: colorScheme, keyword: "cues")
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "How is your body feeling?", arrayOptions: feelingType, selected: $feeling)
                    
                    Button {
                        let report: SessionReport = SessionReport(user_id: 1, session_rpe: sessionRPE, movement_quality: movementQuality, focus: focus, misses: misses, cues: cues, feeling: feeling)
                        
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
            .alert(viewModel.alertTitle, isPresented: $viewModel.alertShown) {} message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    WorkoutReflectionView()
}
