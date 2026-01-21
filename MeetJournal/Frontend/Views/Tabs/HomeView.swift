//
//  HomeView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk
import RevenueCatUI

struct HomeView: View {
    @AppStorage("hasWrittenUserToDB") private var hasWrittenUserToDB: Bool = false
    @AppStorage("userSport") private var userSport: String = ""
    @AppStorage("hasPromptedForNotifications") private var hasPromptedForNotifications: Bool = false
    @AppStorage("trainingDaysStored") private var trainingDaysStored: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.clerk) private var clerk
    @State private var viewModel = UsersViewModel()
    var users: [Users] { viewModel.users }
    var isLoading: Bool { viewModel.isLoading }
    @State private var historyModel = HistoryModel()
    var checkins: [DailyCheckIn] { historyModel.checkIns }
    var historyIsLoading: Bool { historyModel.isLoading }
    @State private var checkInScore = CheckInScore()
    @State private var userOnboardingViewModel = UserOnboardingViewModel()

    @State private var userProfileShown: Bool = false
    @State private var notificationManager = NotificationManager.shared

    @Bindable var onboardingData: OnboardingData

    let date: Date = Date.now

    @State private var editMeetSheetShown: Bool = false
    @State private var newMeetName: String = ""
    @State private var newMeetDate: Date = Date()

    var daysUntilMeet: Int {
        guard let user = users.first else { return 0 }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let meetDate = dateFormatter.date(from: user.next_competition_date) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: meetDate)
        return components.day ?? 0
    }

    var trainingDaysPerWeek: Int {
        users.first?.training_days.count ?? 0
    }

    var sessionsLeft: Int {
        let weeksRemaining = max(0, Double(daysUntilMeet) / 7.0)
        let sessions = Int(ceil(weeksRemaining * Double(trainingDaysPerWeek)))
        return sessions
    }

    var daysUntilMeetText: String {
        if daysUntilMeet < 0 {
            return "Completed"
        } else if daysUntilMeet == 0 {
            return "Today!"
        } else {
            return "\(daysUntilMeet) day\(daysUntilMeet == 1 ? "" : "s") left"
        }
    }

    var sessionsLeftText: String {
        if daysUntilMeet < 0 {
            return "0"
        } else if daysUntilMeet == 0 {
            return "0"
        } else {
            return "\(sessionsLeft) session\(sessionsLeft == 1 ? "" : "s") left"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BackgroundColor()
                
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "pencil.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15)
                                            .foregroundStyle(.secondary)
                                            .padding(.bottom, 3)

                                        Text(users.first?.next_competition ?? "No Meet Coming Up")
                                            .font(.headline.bold())
                                            .padding(.bottom, 4)
                                            .lineLimit(1)
                                    }
                                    Text(daysUntilMeetText)
                                        .font(.headline.bold())
                                        .foregroundStyle(daysUntilMeet < 0 ? .green : blueEnergy)
                                        .padding(.bottom, 4)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(dateFormat(users.first?.next_competition_date ?? "") ?? "N/A")
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 4)

                                    Text(sessionsLeftText)
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 4)
                                }
                            }
                        }
                        .cardStyling()
                        .onTapGesture {
                            newMeetName = users.first?.next_competition ?? ""
                            if let dateString = users.first?.next_competition_date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                if let date = formatter.date(from: dateString) {
                                    newMeetDate = date
                                }
                            }
                            editMeetSheetShown = true
                        }
                        
                        DailyCheckInSection(
                            colorScheme: colorScheme,
                            checkInScore: checkInScore,
                            checkins: checkins,
                            trainingDays: users.first?.training_days ?? [:]
                        )
                        
                        ReflectionSection()
                        
                        HistorySection(checkins: checkins, isLoading: historyIsLoading)
                    }
                    .padding(.top, 100)
                }
                .refreshable {
                    await historyModel.fetchCheckins(user_id: clerk.user?.id ?? "")
                }
                
                if #available(iOS 26.0, * ) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(date.formatted(date: .complete, time: .omitted))")
                                .foregroundStyle(.secondary)
                            
                            if !users.isEmpty {
                                Text("Ready to train, \(users.first?.first_name ?? "")?")
                                    .font(.headline.bold())
                            }
                        }
                        
                        Spacer()
                        
                        
                        Button {
                            userProfileShown = true
                        } label: {
                            if clerk.user == nil {
                                Image(systemName: "person")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(width: 50)
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                    .overlay(
                                        Circle()
                                            .frame(width: 60)
                                            .foregroundStyle(colorScheme == .light ? .gray.opacity(0.3) : .gray.opacity(0.2))
                                    )
                            } else {
                                UserButton()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, 70)
                    .glassEffect(in: .rect(cornerRadius: 32))
                    .padding(.top, -70)
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(date.formatted(date: .complete, time: .omitted))")
                                .foregroundStyle(.secondary)
                            
                            if !users.isEmpty {
                                Text("Ready to train, \(users.first?.first_name ?? "")?")
                                    .font(.headline.bold())
                            }
                        }
                        
                        Spacer()
                        
                        
                        Button {
                            userProfileShown = true
                        } label: {
                            if clerk.user == nil {
                                Image(systemName: "person")
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(width: 50)
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                    .overlay(
                                        Circle()
                                            .frame(width: 60)
                                            .foregroundStyle(colorScheme == .light ? .gray.opacity(0.3) : .gray.opacity(0.2))
                                    )
                            } else {
                                UserButton()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, 70)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.top, -70)
                }
            }
        }
        .task {
            if !hasWrittenUserToDB && clerk.user != nil && !onboardingData.firstName.isEmpty {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = dateFormatter.string(from: onboardingData.nextCompDate)
                let createdAtDate = dateFormatter.string(from: Date())
                
                let newUser = Users(
                    user_id: clerk.user?.id ?? "",
                    first_name: onboardingData.firstName,
                    last_name: onboardingData.lastName,
                    sport: onboardingData.sport,
                    years_of_experience: onboardingData.yearsExperience,
                    meets_per_year: onboardingData.meetsPerYear,
                    goal: onboardingData.goal,
                    biggest_struggle: onboardingData.biggestStruggle,
                    training_days: onboardingData.trainingDays,
                    next_competition: onboardingData.nextComp,
                    next_competition_date: formattedDate,
                    current_tracking_method: onboardingData.currentTrackingMethod,
                    biggest_frustration: onboardingData.biggestFrustration,
                    reflection_frequency: onboardingData.reflectionFrequency,
                    what_holding_back: onboardingData.whatHoldingBack,
                    created_at: createdAtDate
                )
                
                await userOnboardingViewModel.submitUserProfile(user: newUser)
                hasWrittenUserToDB = true
            }
            
            await viewModel.fetchUsers(user_id: clerk.user?.id ?? "")
            
            if let sport = viewModel.users.first?.sport {
                userSport = sport
            }
            
            if let userId = clerk.user?.id,
               let user = viewModel.users.first,
               user.store_token == true {
                let tokenManager = OuraTokenManager()
                await tokenManager.syncRefreshTokenIfStoring(userId: userId)
            }
            
            if !trainingDaysStored, let user = viewModel.users.first {
                notificationManager.storeTrainingDays(user.training_days)
                notificationManager.storeMeetData(
                    meetDate: user.next_competition_date,
                    meetName: user.next_competition
                )
                trainingDaysStored = true
                
                // Request notification permission after onboarding
                if !hasPromptedForNotifications {
                    Task {
                        let granted = await notificationManager.requestPermission()
                        if granted {
                            notificationManager.scheduleNotifications()
                        }
                        hasPromptedForNotifications = true
                    }
                }
            }
            
            // Reschedule notifications on app launch if enabled
            if notificationManager.isEnabled {
                notificationManager.scheduleNotifications()
            }
            
            // Update widget with meet data
            if let user = users.first {
                let sharedDefaults = UserDefaults(suiteName: "group.com.memohnsen.forge.JournalWidget")
                sharedDefaults?.set(user.next_competition, forKey: "meetName")
                sharedDefaults?.set(user.next_competition_date, forKey: "meetDate")
                sharedDefaults?.set(daysUntilMeet, forKey: "daysUntilMeet")
                sharedDefaults?.set(sessionsLeft, forKey: "sessionsLeft")
            }
            
            await historyModel.fetchCheckins(user_id: clerk.user?.id ?? "")
            AnalyticsManager.shared.trackScreenView("HomeView")
        }
        .sheet(isPresented: $userProfileShown) {
            if clerk.user != nil {
                UserProfileView()
            } else {
                AuthView()
            }
        }
        .sheet(isPresented: $editMeetSheetShown) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Meet Name", text: $newMeetName)

                        DatePicker("Meet Date", selection: $newMeetDate, displayedComponents: .date)
                    } header: {
                        Text("Update Next Meet")
                    }
                }
                .navigationTitle("Edit Meet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            editMeetSheetShown = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if #available(iOS 26.0, *) {
                            Button("Save", role: .confirm) {
                                Task {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let formattedDate = dateFormatter.string(from: newMeetDate)

                                    await userOnboardingViewModel.updateUserMeet(
                                        userId: clerk.user?.id ?? "",
                                        meetName: newMeetName,
                                        meetDate: formattedDate
                                    )

                                    await viewModel.fetchUsers(user_id: clerk.user?.id ?? "")

                                    notificationManager.storeMeetData(
                                        meetDate: formattedDate,
                                        meetName: newMeetName
                                    )

                                    if notificationManager.isEnabled {
                                        notificationManager.scheduleNotifications()
                                    }

                                    editMeetSheetShown = false
                                }
                            }
                        } else {
                            Button("Save") {
                                Task {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    let formattedDate = dateFormatter.string(from: newMeetDate)

                                    await userOnboardingViewModel.updateUserMeet(
                                        userId: clerk.user?.id ?? "",
                                        meetName: newMeetName,
                                        meetDate: formattedDate
                                    )

                                    await viewModel.fetchUsers(user_id: clerk.user?.id ?? "")

                                    notificationManager.storeMeetData(
                                        meetDate: formattedDate,
                                        meetName: newMeetName
                                    )

                                    if notificationManager.isEnabled {
                                        notificationManager.scheduleNotifications()
                                    }

                                    editMeetSheetShown = false
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.fraction(0.4)])
            }
        }
    }
}

struct DailyCheckInSection: View {
    var colorScheme: ColorScheme
    @Bindable var checkInScore: CheckInScore
    var checkins: [DailyCheckIn]
    var trainingDays: [String: String]

    var currentStreak: Int {
        CheckInStreakCalculator.currentStreak(
            checkins: checkins,
            trainingDays: trainingDays
        )
    }
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text("Today's Focus")
                        .padding(6)
                        .background(colorScheme == .light ? blueEnergy.opacity(0.1) : blueEnergy.opacity(0.2))
                        .foregroundStyle(blueEnergy)
                        .bold()
                        .clipShape(.rect(cornerRadius: 12))


                    Text("Daily Check-In")
                        .font(.system(size: 24))
                        .bold()
                    
                    if !trainingDays.isEmpty {
                        Text("\(currentStreak)-day streak")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "sun.max")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.orange)
                    .frame(width: 40)
            }
            
            Text("How is your body feeling before today's session? Track your readiness to optimize your training.")
                .foregroundStyle(.secondary)
                .padding(.top, 4)
                .padding(.bottom)
            
            NavigationLink(destination: CheckInView(checkInScore: checkInScore)){
                Text("Start Check-In")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(blueEnergy)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 12))
        }
        .cardStyling()
    }
}

struct ReflectionSection: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading){
            Text("LOG SESSION")
                .foregroundStyle(.secondary)
                .bold()
                .padding(.horizontal)
            
            HStack {
                NavigationLink(destination: WorkoutReflectionView()) {
                    VStack{
                        Image(systemName: "figure.strengthtraining.traditional")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(blueEnergy)
                            .padding()
                            .background(
                                Circle()
                                    .fill(blueEnergy.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        Spacer()
                        Text("""
                             Session
                             Reflection
                             """)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding()
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
                    .padding(.bottom, 12)
                }
                
                NavigationLink(destination: CompReflectionView()) {
                    VStack{
                        Image(systemName: "trophy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(gold)
                            .padding()
                            .background(
                                Circle()
                                    .fill(gold.opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        Spacer()
                        Text("Competition Analysis")
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding()
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
                    .padding(.bottom, 12)
                }
            }
        }
        .padding([.top, .horizontal])
    }
}

struct HistorySection: View {
    @Environment(\.colorScheme) var colorScheme
    var checkins: [DailyCheckIn]
    var isLoading: Bool

    var body: some View {
        if isLoading {
            VStack(alignment: .leading){
                HStack {
                    Text("RECENT ACTIVITY")
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    NavigationLink(destination: HistoryView()){
                        Text("VIEW ALL")
                            .foregroundStyle(.blue)
                            .bold()
                            .padding(.horizontal)
                    }
                }
                
                CustomProgressView(maxNum: 3)
            }
            .padding([.top, .horizontal])
        } else if !checkins.isEmpty {
            VStack(alignment: .leading){
                HStack {
                    Text("RECENT ACTIVITY")
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    NavigationLink(destination: HistoryView()){
                        Text("VIEW ALL")
                            .foregroundStyle(.blue)
                            .bold()
                            .padding(.horizontal)
                    }
                }
                
                ForEach(checkins.prefix(5), id: \.id) { checkin in
                    HStack {
                        NavigationLink(destination: HistoryDetailsView(title: checkin.selected_lift, searchTerm: checkin.selected_lift, selection: "Check-Ins", date: checkin.check_in_date)) {
                            VStack {
                                Text("\(checkin.selected_intensity) \(checkin.selected_lift)")
                                    .font(.title3.bold())
                                    .multilineTextAlignment(.center)
                                
                                Text("\(dateFormat(checkin.check_in_date) ?? checkin.check_in_date) • \(checkin.overall_score)% Preparedness")
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
                                            .stroke(colorScheme == .light ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
            .padding([.top, .horizontal])
        }
    }
}

#Preview {
    HomeView(onboardingData: OnboardingData())
}
