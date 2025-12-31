//
//  MentalExercisesView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/31/25.
//

import SwiftUI

struct MentalExercisesView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack{
                        ExerciseCardSection(
                            title: "Box Breathing",
                            description: "Box breathing can help to improve focus, calm the nervous system, and reduce stress. Try this before a heavy attempt or after your session.",
                            action: {
                                
                            }
                        )
                        
                        ExerciseCardSection(
                            title: "Visualization Prompt",
                            description: "Visualization can help to improve consistency and confidence, as well as calm nerves regarding certain lifts or weights.",
                            action: {
                                
                            }
                        )
                    }
                    .padding(.bottom, 30)
                    .padding(.top)
                }
            }
            .navigationTitle("Exercises")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

struct ExerciseCardSection: View {
    var title: String
    var description: String
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
            Text(description)
                .padding(.top, 1)
            
            Button{
                action()
            } label: {
                Text("Begin Session")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(blueEnergy)
                    .clipShape(.rect(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.top, 6)
            }
        }
        .cardStyling()
    }
}

#Preview {
    MentalExercisesView()
}
