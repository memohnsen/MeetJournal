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
                        Text("Box Breathing")
                            .cardStyling()
                        Text("Visualization Prompt")
                            .cardStyling()
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

#Preview {
    MentalExercisesView()
}
