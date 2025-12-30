//
//  AllHistoryView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

struct HistoryDetailsView: View {
    @AppStorage("userSport") private var userSport: String = ""
    @Environment(\.clerk) private var clerk
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = HistoryModel()
    @State private var deleteModel = DeleteOneModel()
    var isLoading: Bool { viewModel.isLoading }
    var comp: [CompReport] { viewModel.comp }
    var session: [SessionReport] { viewModel.session }
    var checkin: [DailyCheckIn] { viewModel.checkin }
    var title: String
    var searchTerm: String
    var selection: String
    var date: String
    var reportId: Int?
    
    var shareTextResult: String {
        if selection == "Meets" {
            if userSport == "Olympic Weightlifting" {
                return """
                    Meet Results for \(comp.first?.meet ?? "") - \(dateFormat(comp.first?.meet_date ?? "") ?? "")
                
                    Bodyweight: \(comp.first?.bodyweight ?? "")
                
                    \(comp.first?.snatch_best ?? 0)/\(comp.first?.cj_best ?? 0)/\((comp.first?.snatch_best ?? 0) + (comp.first?.cj_best ?? 0))
                
                    Performance Rating: \(comp.first?.performance_rating ?? 0)/5
                    Preparedness Rating: \(comp.first?.preparedness_rating ?? 0)/5
                
                    How my nutrition was: \(comp.first?.nutrition ?? "")
                
                    How my hydration was: \(comp.first?.hydration ?? "")
                
                    What I did well: \(comp.first?.did_well ?? "")
                
                    What I could have done better: \(comp.first?.needs_work ?? "")
                
                    What in training helped me feel prepared: \(comp.first?.good_from_training ?? "")
                
                    Cues that helped: \(comp.first?.cues ?? "")
                
                    What I need to focus on next meet: \(comp.first?.focus ?? "")
                
                    Powered By MeetJournal
                """
            } else {
                return """
                    Meet Results for \(comp.first?.meet ?? "") - \(dateFormat(comp.first?.meet_date ?? "") ?? "")
                
                    Bodyweight: \(comp.first?.bodyweight ?? "")
                
                    \(comp.first?.squat_best ?? 0)/\(comp.first?.bench_best ?? 0)/\(comp.first?.deadlift_best ?? 0)/\((comp.first?.squat_best ?? 0) + (comp.first?.bench_best ?? 0) + (comp.first?.deadlift_best ?? 0))
                
                    Performance Rating: \(comp.first?.performance_rating ?? 0)/5
                    Preparedness Rating: \(comp.first?.preparedness_rating ?? 0)/5
                
                    How my nutrition was: \(comp.first?.nutrition ?? "")
                
                    How my hydration was: \(comp.first?.hydration ?? "")
                
                    What I did well: \(comp.first?.did_well ?? "")
                
                    What I could have done better: \(comp.first?.needs_work ?? "")
                
                    What in training helped me feel prepared: \(comp.first?.good_from_training ?? "")
                
                    Cues that helped: \(comp.first?.cues ?? "")
                
                    What I need to focus on next meet: \(comp.first?.focus ?? "")
                
                    Powered By MeetJournal
                """
            }
        } else if selection == "Workouts" {
            return """
                Session Results for \(dateFormat(session.first?.session_date ??  "") ?? "")
                I trained in the \(session.first?.time_of_day ?? "")
                Session Focus: \(session.first?.selected_intensity ?? "") \(session.first?.selected_lift ?? "")
            
                Session RPE: \(session.first?.session_rpe ?? 0)/5
                Movement Quality Rating: \(session.first?.movement_quality ?? 0)/5
                Focus Rating: \(session.first?.focus ?? 0)/5
                Count of Misses: \(session.first?.misses ?? "")
                Helpful Cues: \(session.first?.cues ?? "")
            
                My body is feeling: \(session.first?.feeling ?? 0)/5
            
                Powered By MeetJournal
            """
        } else {
            return """
                Check-In Results for \(dateFormat(checkin.first?.check_in_date ?? "") ?? "")
            
                Overall Readiness: \(checkin.first?.overall_score ?? 0)%
                Physical Readiness: \(checkin.first?.physical_score ?? 0)%
                Mental Readiness: \(checkin.first?.mental_score ?? 0)%
            
                Physical Rating: \(checkin.first?.physical_strength ?? 0)/5
                Mental Rating: \(checkin.first?.mental_strength ?? 0)/5
                Recovery Rating: \(checkin.first?.recovered ?? 0)/5
                Confidence Rating: \(checkin.first?.confidence ?? 0)/5
                Sleep Rating: \(checkin.first?.sleep ?? 0)/5
                Energy Rating: \(checkin.first?.energy ?? 0)/5
                Stress Rating: \(checkin.first?.stress ?? 0)/5
                Soreness Rating: \(checkin.first?.soreness ?? 0)/5
            
                Daily Goal: \(checkin.first?.goal ?? "")
            
                Powered By MeetJournal
            """
        }
    }
    
    var pageTitle: String {
        if selection == "Meets" {
            return comp.first?.meet ?? ""
        } else if selection == "Workouts" {
            return (session.first?.selected_intensity ?? "") + " " + (session.first?.selected_lift ?? "")
        } else {
            return (checkin.first?.selected_intensity ?? "") + " " + (checkin.first?.selected_lift ?? "")
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView{
                        if selection == "Meets" {
                            CompDisplaySection(comp: comp, userSport: userSport)
                        } else if selection == "Workouts" {
                            SessionDisplaySection(session: session)
                        } else {
                            CheckInDisplaySection(checkin: checkin)
                        }
                    }
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem{
                    ShareLink(item: shareTextResult, subject: Text("Share Your Results")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarSpacer()
                ToolbarItem{
                    Button(role: .destructive) {
                        Task {
                            if let reportId {
                                if selection == "Meets" {
                                    await deleteModel.deleteCompReport(reportId: comp.first?.id ?? 0)
                                } else if selection == "Workouts" {
                                    await deleteModel.deleteSessionReport(reportId: session.first?.id ?? 0)
                                } else {
                                    await deleteModel.deleteCheckIn(checkInId: checkin.first?.id ?? 0)
                                }
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .task {
                if selection == "Meets" {
                    await viewModel.fetchCompDetails(user_id: clerk.user?.id ?? "", title: title, date: date)
                } else if selection == "Workouts" {
                    await viewModel.fetchSessionDetails(user_id: clerk.user?.id ?? "", title: searchTerm, date: date)
                } else {
                    await viewModel.fetchCheckInDetails(user_id: clerk.user?.id ?? "", title: searchTerm, date: date)
                }
            }
        }
    }
}

struct ResultsDisplaySection: View {
    var comp: [CompReport]
    var userSport: String
    
    var body: some View {
        VStack{
            if userSport == "Olympic Weightlifting" {
                VStack{
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
            } else {
                VStack{
                    HStack{
                        Text("Squat")
                            .font(.headline.bold())
                            .frame(width: 105)
                        Spacer()
                        Text("\(comp.first?.squat1 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.squat2 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.squat3 ?? "0")kg")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)

                    HStack{
                        Text("Bench")
                            .font(.headline.bold())
                            .frame(width: 105)
                        Spacer()
                        Text("\(comp.first?.bench1 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.bench2 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.bench3 ?? "0")kg")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)
                    
                    HStack{
                        Text("Deadlift")
                            .font(.headline.bold())
                            .frame(width: 105)
                        Spacer()
                        Text("\(comp.first?.deadlift1 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.deadlift2 ?? "0")kg")
                        Spacer()
                        Text("\(comp.first?.deadlift3 ?? "0")kg")
                    }
                    .padding(.horizontal)
                }
                .cardStyling()
            }
        }
    }
}

struct RatingDisplaySection: View {
    var title: String
    var value: String
    
    var colorByRating: Color {
        if title == "How many lifts did you miss?" {
            if Int(value) ?? 0 <= 1 {
                .green
            } else if Int(value) ?? 0 == 2 {
                blueEnergy
            } else {
                .red
            }
        } else {
            if Int(value) ?? 3 <= 2 {
                .red
            } else if Int(value) ?? 3 == 3 {
                blueEnergy
            } else {
                .green
            }
        }
    }
    
    var body: some View {
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding(.bottom, 2)
            
            if title == "How many lifts did you miss?" || title == "Overall Readiness" || title == "Physical Readiness" || title == "Mental Readiness" {
                Text("\(value)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(colorByRating)
            } else {
                Text("\(value)/5")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(colorByRating)
            }
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
    var userSport: String
    
    var body: some View {
        ResultsDisplaySection(comp: comp, userSport: userSport)
            .padding(.top)
        
        TextDisplaySection(title: "Bodyweight", value: "\(comp.first?.bodyweight ?? "")")
        
        RatingDisplaySection(title: "How would you rate your performance?", value: "\(comp.first?.performance_rating ?? 0)")
        
        RatingDisplaySection(title: "How would you rate your preparedness?", value: "\(comp.first?.preparedness_rating ?? 0)")
        
        TextDisplaySection(title: "How was your nutrition?", value: "\(comp.first?.nutrition ?? "")")
        
        TextDisplaySection(title: "How was your hydration?", value: "\(comp.first?.hydration ?? "")")
        
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
        TextDisplaySection(title: "Time of day you trained", value: "\(session.first?.time_of_day ?? "")")
        
        RatingDisplaySection(title: "How hard was this session?", value: "\(session.first?.session_rpe ?? 0)")
        
        RatingDisplaySection(title: "How was your movement quality?", value: "\(session.first?.movement_quality ?? 0)")

        RatingDisplaySection(title: "How was your focus?", value: "\(session.first?.focus ?? 0)")

        RatingDisplaySection(title: "How many lifts did you miss?", value: "\(session.first?.misses ?? "")")

        TextDisplaySection(title: "What cues made a difference?", value: "\(session.first?.cues ?? "")")

        RatingDisplaySection(title: "How is your body feeling?", value: "\(session.first?.feeling ?? 0)")
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
    HistoryDetailsView(title: "American Open Finals", searchTerm: "American Open Finals", selection: "Workouts", date: "2025-12-26", reportId: 1)
}
