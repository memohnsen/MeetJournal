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
            ForEach(compReports, id: \.self) { report in
                HistoryComponent(
                    colorScheme: colorScheme,
                    title: report.meet,
                    subtitle1: "DATE",
                    subtitle2: "• \(report.snatch_best)/\(report.cj_best)/\(report.snatch_best + report.cj_best)"
                )
            }
            .padding(.horizontal)
        } else if selection == "Workouts" {
            ForEach(sessionReports, id: \.self) { report in
                HistoryComponent(
                    colorScheme: colorScheme,
                    title: "\(report.selected_intensity) \(report.selected_lift) Session",
                    subtitle1: "DATE",
                    subtitle2: nil
                )
            }
            .padding(.horizontal)
        } else {
            ForEach(checkins, id: \.self) { report in
                HistoryComponent(
                    colorScheme: colorScheme,
                    title: "\(report.selected_intensity) \(report.selected_lift) Session",
                    subtitle1: "\(report.overall_score)% Preparedness",
                    subtitle2: "DATE"
                )
            }
            .padding(.horizontal)
        }
    }
}

struct HistoryComponent: View {
    var colorScheme: ColorScheme
    var title: String
    var subtitle1: String
    var subtitle2: String?
    
    var body: some View {
        HStack {
            NavigationLink(destination: HistoryDetailsView()) {
                VStack {
                    Text(title)
                        .font(.title3.bold())
                    HStack{
                        Text(subtitle1)
                        
                        if (subtitle2 == nil) {
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
