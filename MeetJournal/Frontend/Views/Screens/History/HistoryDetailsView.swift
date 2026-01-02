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
    @State private var ouraService = Oura()
    @State private var ouraSleepData: OuraSleep? = nil
    @State private var whoopService = Whoop()
    @State private var whoopData: WhoopDailyData? = nil
    var isLoading: Bool { viewModel.isLoading }
    var comp: [CompReport] { viewModel.comp }
    var session: [SessionReport] { viewModel.session }
    var checkin: [DailyCheckIn] { viewModel.checkin }
    var title: String
    var searchTerm: String
    var selection: String
    var date: String
    var reportId: Int?
    
    var isOuraConnected: Bool {
        guard let userId = clerk.user?.id else { return false }
        return ouraService.getAccessToken(userId: userId) != nil
    }
    
    var isWhoopConnected: Bool {
        guard let userId = clerk.user?.id else { return false }
        return whoopService.getAccessToken(userId: userId) != nil
    }
    
    var ouraShareText: String {
        guard let ouraData = ouraSleepData else { return "" }
        var text = "\n"
        if let sleepHours = ouraData.sleepDurationHours {
            text += "Sleep Duration: \(String(format: "%.1f", sleepHours)) hrs\n"
        }
        if let hrv = ouraData.averageHrv {
            text += "HRV: \(String(format: "%.0f", hrv)) ms\n"
        }
        if let readinessScore = ouraData.readinessScore {
            text += "Readiness Score: \(readinessScore)\n"
        }
        if let avgHeartRate = ouraData.averageHeartRate {
            text += "Average Heart Rate: \(String(format: "%.0f", avgHeartRate)) bpm\n"
        }
        return text.isEmpty ? "" : text
    }
    
    var whoopShareText: String {
        guard let whoopData = whoopData else { return "" }
        var text = "\n"
        if let recoveryScore = whoopData.recoveryScore {
            text += "Recovery Score: \(recoveryScore)%\n"
        }
        if let sleepHours = whoopData.sleepDurationHours {
            text += "Sleep Duration: \(String(format: "%.1f", sleepHours)) hrs\n"
        }
        if let sleepPerformance = whoopData.sleepPerformance {
            text += "Sleep Performance: \(sleepPerformance)%\n"
        }
        if let strainScore = whoopData.strainScore {
            text += "Strain Score: \(String(format: "%.1f", strainScore))\n"
        }
        if let hrv = whoopData.hrvMs {
            text += "HRV: \(hrv) ms\n"
        }
        if let restingHeartRate = whoopData.restingHeartRate {
            text += "Resting Heart Rate: \(restingHeartRate) bpm\n"
        }
        return text.isEmpty ? "" : text
    }
    
    var shareTextResult: String {
        if selection == "Meets" {
            if userSport == "Olympic Weightlifting" {
                return """
                    Meet Results for \(comp.first?.meet ?? "") - \(dateFormat(comp.first?.meet_date ?? "") ?? "")
                
                    Bodyweight: \(comp.first?.bodyweight ?? "")
                
                    \(comp.first?.snatch_best ?? 0)/\(comp.first?.cj_best ?? 0)/\((comp.first?.snatch_best ?? 0) + (comp.first?.cj_best ?? 0))
                
                    Performance Rating: \(comp.first?.performance_rating ?? 0)/5
                    Physical Preparedness Rating: \(comp.first?.physical_preparedness_rating ?? 0)/5
                    Mental Preparedness Rating: \(comp.first?.mental_preparedness_rating ?? 0)/5
                
                    How my nutrition was: \(comp.first?.nutrition ?? "")
                
                    How my hydration was: \(comp.first?.hydration ?? "")
                
                    What I did well: \(comp.first?.did_well ?? "")
                
                    What I could have done better: \(comp.first?.needs_work ?? "")
                
                    What in training helped me feel prepared: \(comp.first?.good_from_training ?? "")
                
                    Cues that helped: \(comp.first?.cues ?? "")
                
                    Satisfaction: \(comp.first?.satisfaction ?? 0)/5
                    Confidence: \(comp.first?.confidence ?? 0)/5
                    Pressure Handling: \(comp.first?.pressure_handling ?? 0)/5
                
                    What I learned about myself: \(comp.first?.what_learned ?? "")
                
                    What I'm most proud of: \(comp.first?.what_proud_of ?? "")
                
                    What I need to focus on next meet: \(comp.first?.focus ?? "")

                    \(ouraShareText)
                    
                    \(whoopShareText)
                    
                    Powered By Forge - Performance Journal
                """
            } else {
                return """
                    Meet Results for \(comp.first?.meet ?? "") - \(dateFormat(comp.first?.meet_date ?? "") ?? "")
                
                    Bodyweight: \(comp.first?.bodyweight ?? "")
                
                    \(comp.first?.squat_best ?? 0)/\(comp.first?.bench_best ?? 0)/\(comp.first?.deadlift_best ?? 0)/\((comp.first?.squat_best ?? 0) + (comp.first?.bench_best ?? 0) + (comp.first?.deadlift_best ?? 0))
                
                    Performance Rating: \(comp.first?.performance_rating ?? 0)/5
                    Physical Preparedness Rating: \(comp.first?.physical_preparedness_rating ?? 0)/5
                    Mental Preparedness Rating: \(comp.first?.mental_preparedness_rating ?? 0)/5
                
                    How my nutrition was: \(comp.first?.nutrition ?? "")
                
                    How my hydration was: \(comp.first?.hydration ?? "")
                
                    What I did well: \(comp.first?.did_well ?? "")
                
                    What I could have done better: \(comp.first?.needs_work ?? "")
                
                    What in training helped me feel prepared: \(comp.first?.good_from_training ?? "")
                
                    Cues that helped: \(comp.first?.cues ?? "")
                
                    Satisfaction: \(comp.first?.satisfaction ?? 0)/5
                    Confidence: \(comp.first?.confidence ?? 0)/5
                    Pressure Handling: \(comp.first?.pressure_handling ?? 0)/5
                
                    What I learned about myself: \(comp.first?.what_learned ?? "")
                
                    What I'm most proud of: \(comp.first?.what_proud_of ?? "")
                
                    What I need to focus on next meet: \(comp.first?.focus ?? "")

                    \(ouraShareText)

                    \(whoopShareText)

                    Powered By Forge - Performance Journal
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
                Satisfaction: \(session.first?.satisfaction ?? 0)/5
                Confidence: \(session.first?.confidence ?? 0)/5
            
                What I learned: \(session.first?.what_learned ?? "")
                What I would do differently: \(session.first?.what_would_change ?? "")

                \(ouraShareText)
                
                \(whoopShareText)
                
                Powered By Forge - Performance Journal
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
                Readiness: \(checkin.first?.readiness ?? 0)/5
                Focus: \(checkin.first?.focus ?? 0)/5
                Excitement: \(checkin.first?.excitement ?? 0)/5
                Body Connection: \(checkin.first?.body_connection ?? 0)/5
            
                Daily Goal: \(checkin.first?.goal ?? "")
                Concerns: \(checkin.first?.concerns ?? "")

                \(ouraShareText)
                
                \(whoopShareText)
                
                Powered By Forge - Performance Journal
            """
        }
    }
    
    var pageTitle: String {
        if selection == "Meets" {
            return comp.first?.meet ?? "Loading..."
        } else if selection == "Workouts" {
            return (session.first?.selected_intensity ?? "Loading") + " " + (session.first?.selected_lift ?? "...")
        } else {
            return (checkin.first?.selected_intensity ?? "Loading") + " " + (checkin.first?.selected_lift ?? "...")
        }
    }

    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                if isLoading {
                    ScrollView {
                        VStack {
                            HistoryDetailsLoadingView()
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    ScrollView{
                        VStack{
                            if selection == "Meets" {
                                CompDisplaySection(comp: comp, userSport: userSport, ouraSleepData: ouraSleepData, whoopData: whoopData)
                            } else if selection == "Workouts" {
                                SessionDisplaySection(session: session, ouraSleepData: ouraSleepData, whoopData: whoopData)
                            } else {
                                CheckInDisplaySection(checkin: checkin, ouraSleepData: ouraSleepData, whoopData: whoopData)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem{
                    ShareLink(item: shareTextResult, subject: Text("Share Your Results")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                if #available(iOS 26.0, *) {
                    ToolbarSpacer()
                }
                ToolbarItem{
                    Button(role: .destructive) {
                        Task {
                            if selection == "Meets" {
                                await deleteModel.deleteCompReport(reportId: comp.first?.id ?? 0)
                                AnalyticsManager.shared.trackCompReflectionDeleted(compId: comp.first?.id ?? 0)
                            } else if selection == "Workouts" {
                                await deleteModel.deleteSessionReport(reportId: session.first?.id ?? 0)
                                AnalyticsManager.shared.trackSessionReflectionDeleted(sessionId: session.first?.id ?? 0)
                            } else {
                                await deleteModel.deleteCheckIn(checkInId: checkin.first?.id ?? 0)
                                AnalyticsManager.shared.trackCheckInDeleted(checkInId: checkin.first?.id ?? 0)
                            }
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .task {
                AnalyticsManager.shared.trackScreenView("HistoryDetailsView")

                if isOuraConnected {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let targetDate = dateFormatter.date(from: date) {
                        do {
                            let calendar = Calendar.current
                            let startDate = calendar.date(byAdding: .day, value: -2, to: targetDate) ?? targetDate
                            let endDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
                            
                            let sleepData = try await ouraService.fetchDailySleep(
                                userId: clerk.user?.id ?? "",
                                startDate: startDate,
                                endDate: endDate
                            )
                            
                            ouraSleepData = sleepData.first { sleepRecord in
                                sleepRecord.day == date
                            }
                            
                            if ouraSleepData == nil {
                                print("⚠️ No Oura data found for date: \(date) (searched \(sleepData.count) records)")
                            } else {
                                print("✅ Found Oura data for date: \(date)")
                            }
                        } catch {
                            print("❌ Error fetching Oura data: \(error)")
                            ouraSleepData = nil
                        }
                    } else {
                        print("⚠️ Could not parse date: \(date)")
                    }
                } else {
                    ouraSleepData = nil
                }
                
                print("🔍 [HistoryDetailsView] Checking WHOOP connection status")
                if isWhoopConnected {
                    print("✅ [HistoryDetailsView] WHOOP is connected, fetching data")
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let targetDate = dateFormatter.date(from: date) {
                        do {
                            print("📅 [HistoryDetailsView] Target date: \(date)")
                            let calendar = Calendar.current
                            let startDate = calendar.date(byAdding: .day, value: -2, to: targetDate) ?? targetDate
                            let endDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
                            
                            print("📅 [HistoryDetailsView] Fetching WHOOP data from \(startDate) to \(endDate)")
                            
                            async let recoveryData = whoopService.fetchRecovery(
                                userId: clerk.user?.id ?? "",
                                startDate: startDate,
                                endDate: endDate
                            )
                            
                            async let sleepData = whoopService.fetchSleep(
                                userId: clerk.user?.id ?? "",
                                startDate: startDate,
                                endDate: endDate
                            )
                            
                            async let cycleData = whoopService.fetchCycle(
                                userId: clerk.user?.id ?? "",
                                startDate: startDate,
                                endDate: endDate
                            )
                            
                            let (recoveries, sleeps, cycles) = try await (recoveryData, sleepData, cycleData)
                            
                            print("📊 [HistoryDetailsView] Fetched \(recoveries.count) recovery records, \(sleeps.count) sleep records, \(cycles.count) cycle records")
                            
                            let dateOnlyFormatter = DateFormatter()
                            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
                            
                            let targetDateString = dateOnlyFormatter.string(from: targetDate)
                            print("🔍 [HistoryDetailsView] Looking for data matching date: \(targetDateString)")
                            
                            let matchingRecovery = recoveries.first { recovery in
                                let isoFormatter = ISO8601DateFormatter()
                                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                if let recoveryDate = isoFormatter.date(from: recovery.start) {
                                    let recoveryDateString = dateOnlyFormatter.string(from: recoveryDate)
                                    return recoveryDateString == targetDateString
                                }
                                return false
                            }
                            
                            let matchingSleep = sleeps.first { sleep in
                                let isoFormatter = ISO8601DateFormatter()
                                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                if let sleepDate = isoFormatter.date(from: sleep.start) {
                                    let sleepDateString = dateOnlyFormatter.string(from: sleepDate)
                                    return sleepDateString == targetDateString
                                }
                                return false
                            }
                            
                            let matchingCycle = cycles.first { cycle in
                                let isoFormatter = ISO8601DateFormatter()
                                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                if let cycleDate = isoFormatter.date(from: cycle.start) {
                                    let cycleDateString = dateOnlyFormatter.string(from: cycleDate)
                                    return cycleDateString == targetDateString
                                }
                                return false
                            }
                            
                            if matchingRecovery != nil || matchingSleep != nil || matchingCycle != nil {
                                whoopData = WhoopDailyData(
                                    recovery: matchingRecovery,
                                    sleep: matchingSleep,
                                    cycle: matchingCycle
                                )
                                print("✅ [HistoryDetailsView] Found WHOOP data for date: \(date)")
                            } else {
                                print("⚠️ [HistoryDetailsView] No WHOOP data found for date: \(date)")
                                whoopData = nil
                            }
                        } catch {
                            print("❌ [HistoryDetailsView] Error fetching WHOOP data: \(error)")
                            print("❌ [HistoryDetailsView] Error details: \(error.localizedDescription)")
                            whoopData = nil
                        }
                    } else {
                        print("⚠️ [HistoryDetailsView] Could not parse date: \(date)")
                        whoopData = nil
                    }
                } else {
                    print("ℹ️ [HistoryDetailsView] WHOOP is not connected")
                    whoopData = nil
                }
                
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
            } else if Int(value) ?? 2 == 2 {
                blueEnergy
            } else {
                .red
            }
        } else if title == "How hard did this session feel?" || title == "How sore does your body feel?" {
            if Int(value) ?? 3 <= 2 {
                .green
            } else if Int(value) ?? 3 == 3 {
                blueEnergy
            } else {
                .red
            }
        } else if title == "Sleep Duration" || title == "HRV" || title == "Readiness Score" || title == "Average Heart Rate" {
            blueEnergy
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
            
            if title == "How many lifts did you miss?" || title == "Overall Readiness" || title == "Physical Readiness" || title == "Mental Readiness" || title == "Sleep Duration" || title == "HRV" || title == "Readiness Score" || title == "Average Heart Rate" || title == "Total" || title == "Misses" {
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
    var ouraSleepData: OuraSleep?
    var whoopData: WhoopDailyData?
    
    var body: some View {
        ResultsDisplaySection(comp: comp, userSport: userSport)
            .padding(.top)
        
        if userSport == "Olympic Weightlifting" {
            RatingDisplaySection(title: "Total", value: ("\((comp.first?.snatch_best ?? 0) + (comp.first?.cj_best ?? 0))kg"))
        } else {
            RatingDisplaySection(title: "Total", value:("\((comp.first?.squat_best ?? 0) + (comp.first?.bench_best ?? 0) + (comp.first?.deadlift_best ?? 0))kg"))
        }
                
        TextDisplaySection(title: "Bodyweight", value: "\(comp.first?.bodyweight ?? "")")
        
        RatingDisplaySection(title: "How would you rate your performance?", value: "\(comp.first?.performance_rating ?? 0)")
        
        RatingDisplaySection(title: "How would you rate your physical preparedness?", value: "\(comp.first?.physical_preparedness_rating ?? 0)")
        
        RatingDisplaySection(title: "How would you rate your mental preparedness?", value: "\(comp.first?.mental_preparedness_rating ?? 0)")

        TextDisplaySection(title: "How was your nutrition?", value: "\(comp.first?.nutrition ?? "")")
        
        TextDisplaySection(title: "How was your hydration?", value: "\(comp.first?.hydration ?? "")")
        
        TextDisplaySection(title: "What did you do well?", value: "\(comp.first?.did_well ?? "")")

        TextDisplaySection(title: "What could you have done better?", value: "\(comp.first?.needs_work ?? "")")
        
        TextDisplaySection(title: "What in training helped you feel prepared for the platform?", value: "\(comp.first?.good_from_training ?? "")")

        TextDisplaySection(title: "What cues worked best for you?", value: "\(comp.first?.cues ?? "")")
        
        RatingDisplaySection(title: "How satisfied do you feel with this meet?", value: "\(comp.first?.satisfaction ?? 0)")
        
        RatingDisplaySection(title: "How confident do you feel after this meet?", value: "\(comp.first?.confidence ?? 0)")
        
        RatingDisplaySection(title: "How did you handle pressure during the meet?", value: "\(comp.first?.pressure_handling ?? 0)")
        
        TextDisplaySection(title: "What did you learn about yourself during this meet?", value: "\(comp.first?.what_learned ?? "")")
        
        TextDisplaySection(title: "What are you most proud of from this meet?", value: "\(comp.first?.what_proud_of ?? "")")
        
        TextDisplaySection(title: "What do you need to focus on for the next meet?", value: "\(comp.first?.focus ?? "")")
                    
        if let ouraData = ouraSleepData {
            if let sleepHours = ouraData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let hrv = ouraData.averageHrv {
                RatingDisplaySection(title: "HRV", value: String(format: "%.0f ms", hrv))
            }
            
            if let readinessScore = ouraData.readinessScore {
                RatingDisplaySection(title: "Readiness Score", value: "\(readinessScore)")
            }
            
            if let avgHeartRate = ouraData.averageHeartRate {
                RatingDisplaySection(title: "Average Heart Rate", value: String(format: "%.0f bpm", avgHeartRate))
            }
        }
        
        if let whoopData = whoopData {
            if let recoveryScore = whoopData.recoveryScore {
                RatingDisplaySection(title: "Recovery Score", value: "\(recoveryScore)%")
            }
            
            if let sleepHours = whoopData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let sleepPerformance = whoopData.sleepPerformance {
                RatingDisplaySection(title: "Sleep Performance", value: "\(sleepPerformance)%")
            }
            
            if let strainScore = whoopData.strainScore {
                RatingDisplaySection(title: "Strain Score", value: String(format: "%.1f", strainScore))
            }
            
            if let hrv = whoopData.hrvMs {
                RatingDisplaySection(title: "HRV", value: "\(hrv) ms")
            }
            
            if let restingHeartRate = whoopData.restingHeartRate {
                RatingDisplaySection(title: "Resting Heart Rate", value: "\(restingHeartRate) bpm")
            }
        }
    }
}

struct SessionDisplaySection: View {
    var session: [SessionReport]
    var ouraSleepData: OuraSleep?
    var whoopData: WhoopDailyData?
    
    var body: some View {
        TextDisplaySection(title: "Time of day you trained", value: "\(session.first?.time_of_day ?? "")")
        
        RatingDisplaySection(title: "How hard did this session feel?", value: "\(session.first?.session_rpe ?? 0)")
        
        RatingDisplaySection(title: "How did your movement quality feel?", value: "\(session.first?.movement_quality ?? 0)")

        RatingDisplaySection(title: "How was your focus during the session?", value: "\(session.first?.focus ?? 0)")

        RatingDisplaySection(title: "How many lifts did you miss?", value: "\(session.first?.misses ?? "")")

        TextDisplaySection(title: "What cues made a difference?", value: "\(session.first?.cues ?? "")")

        RatingDisplaySection(title: "How does your body feel now?", value: "\(session.first?.feeling ?? 0)")
        
        RatingDisplaySection(title: "How satisfied do you feel with this session?", value: "\(session.first?.satisfaction ?? 0)")
        
        RatingDisplaySection(title: "How confident do you feel after this session?", value: "\(session.first?.confidence ?? 0)")
        
        TextDisplaySection(title: "Did you learn anything about yourself during this session?", value: "\(session.first?.what_learned ?? "")")
        
        TextDisplaySection(title: "Would you do anything differently next time?", value: "\(session.first?.what_would_change ?? "")")
            
        if let ouraData = ouraSleepData {
            if let sleepHours = ouraData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let hrv = ouraData.averageHrv {
                RatingDisplaySection(title: "HRV", value: String(format: "%.0f ms", hrv))
            }
            
            if let readinessScore = ouraData.readinessScore {
                RatingDisplaySection(title: "Readiness Score", value: "\(readinessScore)")
            }
            
            if let avgHeartRate = ouraData.averageHeartRate {
                RatingDisplaySection(title: "Average Heart Rate", value: String(format: "%.0f bpm", avgHeartRate))
            }
        }
        
        if let whoopData = whoopData {
            if let recoveryScore = whoopData.recoveryScore {
                RatingDisplaySection(title: "Recovery Score", value: "\(recoveryScore)%")
            }
            
            if let sleepHours = whoopData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let sleepPerformance = whoopData.sleepPerformance {
                RatingDisplaySection(title: "Sleep Performance", value: "\(sleepPerformance)%")
            }
            
            if let strainScore = whoopData.strainScore {
                RatingDisplaySection(title: "Strain Score", value: String(format: "%.1f", strainScore))
            }
            
            if let hrv = whoopData.hrvMs {
                RatingDisplaySection(title: "HRV", value: "\(hrv) ms")
            }
            
            if let restingHeartRate = whoopData.restingHeartRate {
                RatingDisplaySection(title: "Resting Heart Rate", value: "\(restingHeartRate) bpm")
            }
        }
    }
}

struct CheckInDisplaySection: View {
    var checkin: [DailyCheckIn]
    var ouraSleepData: OuraSleep?
    var whoopData: WhoopDailyData?
    
    var body: some View {        
        RatingDisplaySection(title: "Overall Readiness", value: "\(checkin.first?.overall_score ?? 0)%")
        
        RatingDisplaySection(title: "Physical Readiness", value: "\(checkin.first?.physical_score ?? 0)%")
        
        RatingDisplaySection(title: "Mental Readiness", value: "\(checkin.first?.mental_score ?? 0)%")
        
        TextDisplaySection(title: "What would make today feel like a successful session for you?", value: "\(checkin.first?.goal ?? "")")

        RatingDisplaySection(title: "How strong does your body feel?", value: "\(checkin.first?.physical_strength ?? 0)")
        
        RatingDisplaySection(title: "How strong does your mind feel?", value: "\(checkin.first?.mental_strength ?? 0)")
        
        RatingDisplaySection(title: "How recovered do you feel?", value: "\(checkin.first?.recovered ?? 0)")
        
        RatingDisplaySection(title: "How confident do you feel?", value: "\(checkin.first?.confidence ?? 0)")

        RatingDisplaySection(title: "Rate last night's sleep quality", value: "\(checkin.first?.sleep ?? 0)")
        
        RatingDisplaySection(title: "How energized do you feel?", value: "\(checkin.first?.energy ?? 0)")
        
        RatingDisplaySection(title: "How stressed do you feel?", value: "\(checkin.first?.stress ?? 0)")
        
        RatingDisplaySection(title: "How sore does your body feel?", value: "\(checkin.first?.soreness ?? 0)")
        
        RatingDisplaySection(title: "How ready do you feel to train?", value: "\(checkin.first?.readiness ?? 0)")
        
        RatingDisplaySection(title: "How focused do you feel?", value: "\(checkin.first?.focus ?? 0)")
        
        RatingDisplaySection(title: "How excited do you feel about today's session?", value: "\(checkin.first?.excitement ?? 0)")
        
        RatingDisplaySection(title: "How connected do you feel to your body?", value: "\(checkin.first?.body_connection ?? 0)")
        
        TextDisplaySection(title: "What concerns or worries do you have going into today's session?", value: "\(checkin.first?.concerns ?? "")")
            
        if let ouraData = ouraSleepData {
            if let sleepHours = ouraData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let hrv = ouraData.averageHrv {
                RatingDisplaySection(title: "HRV", value: String(format: "%.0f ms", hrv))
            }
            
            if let readinessScore = ouraData.readinessScore {
                RatingDisplaySection(title: "Readiness Score", value: "\(readinessScore)")
            }
            
            if let avgHeartRate = ouraData.averageHeartRate {
                RatingDisplaySection(title: "Average Heart Rate", value: String(format: "%.0f bpm", avgHeartRate))
            }
        }
        
        if let whoopData = whoopData {
            if let recoveryScore = whoopData.recoveryScore {
                RatingDisplaySection(title: "Recovery Score", value: "\(recoveryScore)%")
            }
            
            if let sleepHours = whoopData.sleepDurationHours {
                RatingDisplaySection(title: "Sleep Duration", value: String(format: "%.1f hrs", sleepHours))
            }
            
            if let sleepPerformance = whoopData.sleepPerformance {
                RatingDisplaySection(title: "Sleep Performance", value: "\(sleepPerformance)%")
            }
            
            if let strainScore = whoopData.strainScore {
                RatingDisplaySection(title: "Strain Score", value: String(format: "%.1f", strainScore))
            }
            
            if let hrv = whoopData.hrvMs {
                RatingDisplaySection(title: "HRV", value: "\(hrv) ms")
            }
            
            if let restingHeartRate = whoopData.restingHeartRate {
                RatingDisplaySection(title: "Resting Heart Rate", value: "\(restingHeartRate) bpm")
            }
        }    
    }
}

struct HistoryDetailsLoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ForEach(1...7, id: \.self) {_ in
            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.white.opacity(isAnimating ? 0.3 : 0.1) : Color.gray.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 200, height: 20)
                    .padding(.bottom, 2)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.white.opacity(isAnimating ? 0.3 : 0.1) : Color.gray.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 250, height: 60)
            }
            .cardStyling()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    HistoryDetailsView(title: "American Open Finals", searchTerm: "American Open Finals", selection: "Workouts", date: "2025-12-26", reportId: 1)
}
