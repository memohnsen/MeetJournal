//
//  CardStyling.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct CardStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(16)
            .foregroundStyle(.black)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 12)
    }
}

extension View {
    func cardStyling() -> some View {
        self.modifier(CardStyling())
    }
}

struct CardStylingSample: View {
    var body: some View {
        ZStack{
            BackgroundColor()
            
            VStack{
                Text("Sample")
            }
            .cardStyling()
        }
    }
}

#Preview {
    CardStylingSample()
}
