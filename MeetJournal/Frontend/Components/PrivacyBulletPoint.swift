//
//  PrivacyBulletPoint.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 1/1/26.
//

import SwiftUI

struct PrivacyBulletPoint: View {
    let text: String
    let textColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .font(.subheadline)
                .foregroundStyle(textColor)
        }
    }
}
