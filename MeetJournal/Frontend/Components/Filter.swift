//
//  Filter.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/26/25.
//

import SwiftUI

struct Filter: View {
    @Binding var selected: String
    let options: [String] = ["Check-Ins", "Workouts", "Meets"]
    
    func selectedButton(_ input: String) -> Color {
        if selected == input {
            return blueEnergy
        } else {
            return blueEnergy.opacity(0.2)
        }
    }
    
    func selectedButtonText(_ input: String) -> Color {
        if selected == input {
            return .white
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack{
            ForEach(options, id: \.self) { option in
                Button{
                    selected = option
                } label: {
                    Text(option)
                        .padding()
                        .background(selectedButton(option))
                        .clipShape(.capsule)
                        .foregroundStyle(selectedButtonText(option))
                        .bold()
                }
            }
            Spacer()
        }
        .padding([.vertical, .horizontal])
    }
}
