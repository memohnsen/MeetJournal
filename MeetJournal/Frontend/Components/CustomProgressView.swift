//
//  CustomProgressView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/27/25.
//

import SwiftUI

struct CustomProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating: Bool = false

    var body: some View {
        ForEach(0..<3, id: \.self) { number in
            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.white.opacity(isAnimating ? 0.3 : 0.1) : Color.gray.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 200, height: 30)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.white.opacity(isAnimating ? 0.3 : 0.1) : Color.gray.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 200, height: 10)
            }
        }
        .frame(height: 50)
        .cardStyling()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    CustomProgressView()
}
