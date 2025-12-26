//
//  AllHistoryView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct HistoryDetailsView: View {
    @State private var viewModel = HistoryModel()
    var comp: [CompReport] { viewModel.comp }
    var session: [SessionReport] { viewModel.session }
    var checkin: [DailyCheckIn] { viewModel.checkin }
    var title: String
    var searchTerm: String
    var selection: String
    var date: String
    
    var pageTitle: String {
        if selection == "Meets" {
            return comp.first?.meet ?? ""
        } else if selection == "Workouts" {
            return (session.first?.selected_intensity ?? "") + " " + (session.first?.selected_lift ?? "")
        } else {
            return (checkin.first?.selected_intensity ?? "") + " " +  (checkin.first?.selected_lift ?? "")
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    if selection == "Meets" {
                        CompDisplaySection(comp: comp)
                    } else if selection == "Workouts" {
                        SessionDisplaySection(session: session)
                    } else {
                        CheckInDisplaySection(checkin: checkin)
                    }
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .task {
                if selection == "Meets" {
                    await viewModel.fetchCompDetails(id: 1, title: title, date: date)
                } else if selection == "Workouts" {
                    await viewModel.fetchSessionDetails(id: 1, title: searchTerm, date: date)
                } else {
                    await viewModel.fetchCheckInDetails(id: 1, title: searchTerm, date: date)
                }
            }
        }
    }
}

struct ResultsDisplaySection: View {
    var comp: [CompReport]
    var body: some View {
        VStack{
            Text("Results")
                .font(.title.bold())
                .padding(.bottom, 6)

            HStack{
                Text("Snatch")
                    .font(.headline.bold())
                    .frame(width: 105)
                Spacer()
                Text("\(comp.first?.snatch1 ?? "0")kg")
                Spacer()
                Text("\(comp.first?.snatch2 ?? "0")kg")
                Spacer()
                Text("\(comp.first?.snatch3 ?? "0")kg")
            }
            .padding([.horizontal, .vertical])
            
            
            HStack{
                Text("Clean & Jerk")
                    .font(.headline.bold())
                    .frame(width: 105)
                Spacer()
                Text("\(comp.first?.cj1 ?? "0")kg")
                Spacer()
                Text("\(comp.first?.cj2 ?? "0")kg")
                Spacer()
                Text("\(comp.first?.cj3 ?? "0")kg")
            }
            .padding(.horizontal)
        }
        .cardStyling()
    }
}

struct RatingDisplaySection: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding(.bottom, 2)
            
            Text("\(value)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(blueEnergy)
        }
        .cardStyling()
    }
}

struct TextDisplaySection: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding(.bottom, 2)
            
            Text(value)
        }
        .cardStyling()
    }
}

struct CompDisplaySection: View {
    var comp: [CompReport]
    
    var body: some View {
        ResultsDisplaySection(comp: comp)
            .padding(.top)
        
        RatingDisplaySection(title: "How would you rate your performance?", value: "\(comp.first?.performance_rating ?? 0)")
        
        RatingDisplaySection(title: "How would you rate your preparedness?", value: "\(comp.first?.preparedness_rating ?? 0)")
        
        TextDisplaySection(title: "What did you do well?", value: "\(comp.first?.did_well ?? "")")

        TextDisplaySection(title: "What could you have done better?", value: "\(comp.first?.needs_work ?? "")")
        
        TextDisplaySection(title: "What in training helped you feel prepared for the platform?", value: "\(comp.first?.good_from_training ?? "")")

        TextDisplaySection(title: "What cues worked best for you?", value: "\(comp.first?.cues ?? "")")
        
        TextDisplaySection(title: "What do you need to focus on for the next meet?", value: "\(comp.first?.focus ?? "")")
            .padding(.bottom, 30)
    }
}

struct SessionDisplaySection: View {
    var session: [SessionReport]
    
    var body: some View {
        RatingDisplaySection(title: "How hard was this session?", value: "\(session.first?.session_rpe ?? 0)")
        
        RatingDisplaySection(title: "How was your movement quality?", value: "\(session.first?.movement_quality ?? 0)")

        RatingDisplaySection(title: "How was your focus?", value: "\(session.first?.focus ?? 0)")

        RatingDisplaySection(title: "How many lifts did you miss?", value: "\(session.first?.misses ?? "")")

        TextDisplaySection(title: "What cues made a difference?", value: "\(session.first?.cues ?? "")")

        RatingDisplaySection(title: "How is your body feeling?", value: "\(session.first?.feeling ?? "")")
            .padding(.bottom, 30)
    }
}

struct CheckInDisplaySection: View {
    var checkin: [DailyCheckIn]
    
    var body: some View {
        RatingDisplaySection(title: "Overall Readiness", value: "\(checkin.first?.overall_score ?? 0)%")
        
        RatingDisplaySection(title: "Physical Readiness", value: "\(checkin.first?.physical_score ?? 0)%")
        
        RatingDisplaySection(title: "Mental Readiness", value: "\(checkin.first?.mental_score ?? 0)%")
        
        TextDisplaySection(title: "What's your goal for this session?", value: "\(checkin.first?.goal ?? "")")

        RatingDisplaySection(title: "How physically strong do you feel?", value: "\(checkin.first?.physical_strength ?? 0)")
        
        RatingDisplaySection(title: "How mentally strong do you feel?", value: "\(checkin.first?.mental_strength ?? 0)")
        
        RatingDisplaySection(title: "How recovered do you feel?", value: "\(checkin.first?.recovered ?? 0)")
        
        RatingDisplaySection(title: "How confident do you feel?", value: "\(checkin.first?.confidence ?? 0)")

        RatingDisplaySection(title: "Rate last night's sleep", value: "\(checkin.first?.sleep ?? 0)")
        
        RatingDisplaySection(title: "Rate your energy", value: "\(checkin.first?.energy ?? 0)")
        
        RatingDisplaySection(title: "Rate your stress", value: "\(checkin.first?.stress ?? 0)")
        
        RatingDisplaySection(title: "Rate your soreness", value: "\(checkin.first?.soreness ?? 0)")
            .padding(.bottom, 30)
    }
}

#Preview {
    HistoryDetailsView(title: "American Open Finals", searchTerm: "American Open Finals", selection: "Meets", date: "2025-12-26")
}
