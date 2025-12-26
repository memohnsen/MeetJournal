//
//  HistoryView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryModel()
    var compReports: [CompReport] { viewModel.compReport }
    var checkins: [DailyCheckIn] { viewModel.checkIns }
    var sessionReports: [SessionReport] { viewModel.sessionReport }
    
    @State private var selected = "Meets"
    let options: [String] = ["Meets", "Workouts", "Check-Ins"]
    
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
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack{
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
                        
                        HistoryCardSection(compReports: compReports, checkins: checkins, sessionReports: sessionReports, selection: selected)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("History")
            .task {
                await viewModel.fetchCompReports(id: 1)
                await viewModel.fetchCheckins(id: 1)
                await viewModel.fetchSessionReport(id: 1)
            }
        }
    }
}

struct HistoryCardSection: View {
    @Environment(\.colorScheme) var colorScheme
    var compReports: [CompReport]
    var checkins: [DailyCheckIn]
    var sessionReports: [SessionReport]
    var selection: String
     
    var body: some View {
        if selection == "Meets" {
            LazyVStack{
                ForEach(compReports, id: \.self) { report in
                    HistoryComponent(
                        colorScheme: colorScheme,
                        searchTerm: report.meet,
                        title: report.meet,
                        subtitle1: "\(dateFormat(report.meet_date) ?? "N/A")",
                        subtitle2: "• \(report.snatch_best)/\(report.cj_best)/\(report.snatch_best + report.cj_best)",
                        selection: selection,
                        date: report.meet_date
                    )
                }
            }
            .padding(.horizontal)
        } else if selection == "Workouts" {
            LazyVStack{
                ForEach(sessionReports, id: \.self) { report in
                    HistoryComponent(
                        colorScheme: colorScheme,
                        searchTerm: report.selected_lift,
                        title: "\(report.selected_intensity) \(report.selected_lift) Session",
                        subtitle1: "\(dateFormat(report.session_date) ?? "N/A")",
                        subtitle2: " • RPE \(report.session_rpe)/5",
                        selection: selection,
                        date: report.session_date
                    )
                }
            }
            .padding(.horizontal)
        } else {
            LazyVStack{
                ForEach(checkins, id: \.self) { report in
                    HistoryComponent(
                        colorScheme: colorScheme,
                        searchTerm: report.selected_lift,
                        title: "\(report.selected_intensity) \(report.selected_lift) Session",
                        subtitle1: "\(dateFormat(report.check_in_date) ?? "N/A")",
                        subtitle2: " • \(report.overall_score)% Preparedness",
                        selection: selection,
                        date: report.check_in_date
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HistoryComponent: View {
    var colorScheme: ColorScheme
    var searchTerm: String
    var title: String
    var subtitle1: String
    var subtitle2: String?
    var selection: String
    var date: String
    
    var body: some View {
        HStack {
            NavigationLink(destination: HistoryDetailsView(title: title, searchTerm: searchTerm, selection: selection, date: date)) {
                VStack {
                    Text(title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    HStack{
                        Text(subtitle1)
                        
                        if (subtitle2 != nil) {
                            Text(subtitle2 ?? "")
                        }
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .light ? .white : .black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.bottom, 12)
            }
        }
    }
}

#Preview {
    HistoryView()
}
