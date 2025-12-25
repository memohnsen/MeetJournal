//
//  TextFieldSection.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct TextFieldSection: View {
    @Binding var field: String
    var title: String
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding([.bottom, .horizontal])
                .multilineTextAlignment(.center)
            
            TextField("Enter your goal...", text: $field, axis: .vertical)
                .padding()
                .frame(height: 120, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(blueEnergy.opacity(0.1))
                )
                .padding(.horizontal)
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

