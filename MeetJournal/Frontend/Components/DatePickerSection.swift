//
//  DatePickerSection.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/26/25.
//

import SwiftUI

struct DatePickerSection: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Text(title)
                    .font(.headline.bold())
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.automatic)
            }
        }
        .cardStyling()
    }
}

