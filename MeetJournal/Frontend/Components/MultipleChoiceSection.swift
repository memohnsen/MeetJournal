//
//  MultipleChoiceSection.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct MultipleChoiceSection: View {
    var colorScheme: ColorScheme
    var title: String
    var arrayOptions: [String]
    @Binding var selected: String
    
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
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding([.bottom, .horizontal])
                .multilineTextAlignment(.center)
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(arrayOptions, id: \.self) { option in
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
                }
                .padding([.bottom, .horizontal])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .foregroundStyle(colorScheme == .light ? .black : .white)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .light ? .white : .black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(colorScheme == .light ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}
