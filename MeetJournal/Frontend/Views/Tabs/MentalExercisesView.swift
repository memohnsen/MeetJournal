//
//  MentalExercisesView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/31/25.
//

import SwiftUI

struct MentalExercisesView: View {
    @State private var navigateToBoxBreathing: Bool = false
    @State private var navigateToVisualization: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(spacing: 0) {
                        ExerciseCardSection(
                            title: "Box Breathing",
                            description: "A breathing exercise to improve focus, calm the nervous system, and reduce stress.",
                            buttonName: "Begin Breathing",
                            action: {
                                navigateToBoxBreathing = true
                            }
                        )
                        
                        ExerciseCardSection(
                            title: "Visualization",
                            description: "Guided meditation to improve consistency, improve confidence, and calm nerves by imagining every aspect of the lift.",
                            buttonName: "Start Visualizing",
                            action: {
                                navigateToVisualization = true
                            }
                        )
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Exercises")
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationDestination(isPresented: $navigateToBoxBreathing) {
                BoxBreathingSetupView()
            }
            .navigationDestination(isPresented: $navigateToVisualization) {
                VisualizationSetupView()
            }
        }
    }
}

struct ExerciseCardSection: View {
    var title: String
    var description: String
    var buttonName: String
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2.bold())
                .padding(.bottom, 8)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            Button{
                action()
            } label: {
                Text(buttonName)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(blueEnergy)
                    .clipShape(.rect(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
        }
        .cardStyling()
    }
}

#Preview {
    MentalExercisesView()
}
