//
//  OnboardingView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

struct OnboardingView: View {
    @State private var userViewModel = UserOnboardingViewModel()
    @State private var pageCounter: Int = 1
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var sport: String = "Olympic Weightlifting"
    @State private var yearsExperience: Int = 3
    @State private var meetsPerYear: Int = 2
    
    @State private var goal: String = ""
    @State private var biggestStruggle: String = "Confidence"
    @State private var trainingDays: [String: String] = [:]
    @State private var nextComp: String = ""
    @State private var nextCompDate: Date = Date.now
    
    var body: some View {
        if pageCounter == 1 {
            OnboardingPageSection(
                pageCounter: $pageCounter,
                image: "chalk_bucket",
                tagline: "The Mental Block",
                taglineColor: .red,
                title: "Is your mindset limiting your total?",
                message: "Physical strength isn't enough. Mental fatigue and lack of reflection can stall your progress for months.",
                buttonText: "I Feel This"
            )
        } else if pageCounter == 2 {
            OnboardingPageSection(
                pageCounter: $pageCounter,
                image: "journal",
                tagline: "The Solution",
                taglineColor: blueEnergy,
                title: "Turn hard sessions into insights",
                message: "A dedicated space to reflect on every lift. Connect your mind to the bar and take action to improve your performance.",
                buttonText: "I Need This"
            )
        } else if pageCounter == 3 {
            OnboardingPageSection(
                pageCounter: $pageCounter,
                image: "high-five",
                tagline: "Track Readiness",
                taglineColor: .green,
                title: "Know when to push and when to deload",
                message: "Daily check-ins and reflections help you understand how your body is holding up. Listen to your body, don't fight against it.",
                buttonText: "I'm Ready"
            )
        } else if pageCounter == 4 {
            OnboardingPageSection(
                pageCounter: $pageCounter,
                image: "platform-lift",
                tagline: "Comp Mindset",
                taglineColor: .purple,
                title: "Analyze the day, own the outcome",
                message: "Post-competition reflections help you process the wins and losses, building bulletproof confidence for your next meet.",
                buttonText: "Let's Do It"
            )
        }
        else if pageCounter == 5 {
            UserInfoSection(
                pageCounter: $pageCounter,
                firstName: $firstName,
                lastName: $lastName,
                sport: $sport,
                yearsExperience: $yearsExperience,
                meetsPerYear: $meetsPerYear,
                buttonText: "Next"
            )
        } else if pageCounter == 6 {
            SportingInfoSection(
                pageCounter: $pageCounter,
                goal: $goal,
                biggestStruggle: $biggestStruggle,
                nextComp: $nextComp,
                nextCompDate: $nextCompDate,
                buttonText: "Next",
                sport: $sport
            )
        } else if pageCounter == 7 {
            TrainingDaysSection(
                userViewModel: userViewModel,
                firstName: firstName,
                lastName: lastName,
                sport: sport,
                yearsExperience: yearsExperience,
                meetsPerYear: meetsPerYear,
                goal: goal,
                biggestStruggle: biggestStruggle,
                nextComp: nextComp,
                nextCompDate: nextCompDate,
                trainingDays: $trainingDays,
                buttonText: "Lets get started!"
            )
        }
    }
}

struct OnboardingPageSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var pageCounter: Int
    var image: String
    var tagline: String
    var taglineColor: Color
    var title: String
    var message: String
    var buttonText: String
    
    var body: some View {
        VStack{
            Image(image)
                .resizable()
                .scaledToFit()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, colorScheme == .light ? .white : .black]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                        
            VStack(alignment: .leading){
                Text(tagline)
                    .padding(6)
                    .background(colorScheme == .light ? taglineColor.opacity(0.1) : taglineColor.opacity(0.2))
                    .foregroundStyle(taglineColor)
                    .bold()
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.bottom, 4)
                
                Text(title)
                    .font(.system(size: 36))
                    .bold()
                    .padding(.bottom, 8)
                
                Text(message)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Text(buttonText)
            }
            .padding()
            .font(.system(size: 20))
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundStyle(.white)
            .bold()
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.bottom, 40)
            .onTapGesture {
                pageCounter += 1
            }
        }
        .ignoresSafeArea()
    }
}

struct UserInfoSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var pageCounter: Int
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var sport: String
    @Binding var yearsExperience: Int
    @Binding var meetsPerYear: Int
    var buttonText: String
    
    let sports: [String] = ["Olympic Weightlifting", "Powerlifting"]
    
    var isDisabled: Bool {
        if firstName.isEmpty || lastName.isEmpty {
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(alignment: .leading){
                        Text("What's your first name?")
                            .font(.headline.bold())
                            .padding(.bottom)
                        TextField("First Name", text: $firstName)
                            .padding(.leading)
                    }
                    .cardStyling()
                    
                    VStack(alignment: .leading){
                        Text("What's your last name?")
                            .font(.headline.bold())
                            .padding(.bottom)
                        TextField("Last Name", text: $lastName)
                            .padding(.leading)
                    }
                    .cardStyling()
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "What's your sport?", arrayOptions: sports, selected: $sport)
                    
                    SliderSection(colorScheme: colorScheme, title: "How many years have you been training?", value: $yearsExperience, minString: "0", maxString: "10+", minValue: 0, maxValue: 10)
                    
                    SliderSection(colorScheme: colorScheme, title: "How many meets do you do per year?", value: $meetsPerYear, minString: "0", maxString: "10+", minValue: 0, maxValue: 10)
                                        
                    HStack {
                        Text(buttonText)
                    }
                    .padding()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .background(!isDisabled ? .gray : .blue)
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!isDisabled)
                    .onTapGesture {
                        pageCounter += 1
                    }
                }
            }
            .navigationTitle("Building Your Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SportingInfoSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var pageCounter: Int
    @Binding var goal: String
    @Binding var biggestStruggle: String
    @Binding var nextComp: String
    @Binding var nextCompDate: Date
    var buttonText: String
    @Binding var sport: String
    
    var sportName: String {
        if sport == "Olympic Weightlifting" {
            return "Weightlifting"
        } else {
            return "Powerlifting"
        }
    }
    
    let struggleOptions: [String] = [
        "Confidence", "Focus", "Self Talk", "Fear", "Comparison", "Pressure", "Consistency"
    ]
    
    var isDisabled: Bool {
        if goal.isEmpty || nextComp.isEmpty {
            return false
        }
        
        return true
    }
        
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    TextFieldSection(field: $goal, title: "What's your next 6-12 month goal?", colorScheme: colorScheme, keyword: "goal")
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "What is the hardest part of \(sportName) mentally for you?", arrayOptions: struggleOptions, selected: $biggestStruggle)
                    
                    TextFieldSection(field: $nextComp, title: "What's your next meet?", colorScheme: colorScheme, keyword: "next meet name")
                    
                    DatePickerSection(title: "Next meet date?", selectedDate: $nextCompDate)
                                        
                    HStack {
                        Text(buttonText)
                    }
                    .padding()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .background(!isDisabled ? .gray : .blue)
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!isDisabled)
                    .onTapGesture {
                        pageCounter += 1
                    }
                }
            }
            .navigationTitle("Building Your Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TrainingDaysSection: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Environment(\.clerk) private var clerk
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPaywallShown: Bool = false
    @State private var isAuthShown: Bool = false
    @State private var showingTimePicker: String? = nil
    
    var userViewModel: UserOnboardingViewModel
    var firstName: String
    var lastName: String
    var sport: String
    var yearsExperience: Int
    var meetsPerYear: Int
    var goal: String
    var biggestStruggle: String
    var nextComp: String
    var nextCompDate: Date
    @Binding var trainingDays: [String: String]
    var buttonText: String
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let timeOptions = [
        "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM"
    ]
    
    func isDaySelected(_ day: String) -> Bool {
        return trainingDays[day] != nil
    }
    
    func selectedDayColor(_ day: String) -> Color {
        return isDaySelected(day) ? blueEnergy : blueEnergy.opacity(0.2)
    }
    
    func selectedDayTextColor(_ day: String) -> Color {
        return isDaySelected(day) ? .white : .blue
    }
    
    var isDisabled: Bool {
        return !trainingDays.isEmpty
    }

    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack{
                        Text("When do you train?")
                            .font(.headline.bold())
                            .padding(.bottom)
                        
                        ForEach(daysOfWeek, id: \.self) { day in
                            HStack(spacing: 16) {
                                Button{
                                    if isDaySelected(day) {
                                        trainingDays.removeValue(forKey: day)
                                        showingTimePicker = nil
                                    } else {
                                        trainingDays[day] = timeOptions[0]
                                    }
                                } label: {
                                    Text(day)
                                        .frame(width: 120)
                                        .padding()
                                        .background(selectedDayColor(day))
                                        .clipShape(.capsule)
                                        .foregroundStyle(selectedDayTextColor(day))
                                        .bold()
                                }
                                
                                if isDaySelected(day) {
                                    Button {
                                        showingTimePicker = day
                                    } label: {
                                        Text(trainingDays[day] ?? timeOptions[0])
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(blueEnergy.opacity(0.2))
                                            .clipShape(.capsule)
                                            .foregroundStyle(.blue)
                                            .bold()
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { showingTimePicker == day },
                                        set: { if !$0 { showingTimePicker = nil } }
                                    )) {
                                        VStack {
                                            Text("Select Time")
                                                .font(.headline)
                                                .padding()
                                            
                                            Picker("Time", selection: Binding(
                                                get: { trainingDays[day] ?? timeOptions[0] },
                                                set: { trainingDays[day] = $0 }
                                            )) {
                                                ForEach(timeOptions, id: \.self) { time in
                                                    Text(time).tag(time)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .padding()
                                            
                                            Button("Done") {
                                                showingTimePicker = nil
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .bold()
                                            .clipShape(.rect(cornerRadius: 12))
                                            .padding()
                                        }
                                        .presentationDetents([.height(350)])
                                    }
                                } else {
                                    Text("Select time")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(.capsule)
                                        .foregroundStyle(.gray)
                                        .bold()
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
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
                    
                    HStack {
                        Text(buttonText)
                    }
                    .padding()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .background(!isDisabled ? .gray : .blue)
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!isDisabled)
                    .onTapGesture {
                        Task {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let formattedDate = dateFormatter.string(from: nextCompDate)
                            
                            let newUser = Users(
                                id: 3,
                                first_name: firstName,
                                last_name: lastName,
                                sport: sport,
                                years_of_experience: yearsExperience,
                                meets_per_year: meetsPerYear,
                                goal: goal,
                                biggest_struggle: biggestStruggle,
                                training_days: trainingDays,
                                next_competition: nextComp,
                                next_competition_date: formattedDate
                            )
                            
                            await userViewModel.submitUserProfile(user: newUser)
                            
                            hasSeenOnboarding = true
                            
                            if clerk.user != nil {
                                isPaywallShown = true
                            } else {
                                isAuthShown = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Building Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPaywallShown) {
                EmptyView()
            }
            .sheet(isPresented: $isAuthShown) {
                AuthView()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
