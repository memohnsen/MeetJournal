//
//  CardStyling.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct CardStyling: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(16)
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
