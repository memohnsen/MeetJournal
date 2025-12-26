//
//  CompReflectionView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct CompReflectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var viewModel = CompReportModel()
    
    @State private var userViewModel = UsersViewModel()
    var user: [Users] { userViewModel.users }
    
    @State private var meet: String = ""
    @State private var selectedMeetType: String = "Local"
    @State private var meetDate: Date = Date()
    @State private var performanceRating: Int = 3
    @State private var preparednessRating: Int = 3
    @State private var didWell: String = ""
    @State private var needsWork: String = ""
    @State private var goodFromTraining: String = ""
    @State private var cues: String = ""
    @State private var focus: String = ""
    
    @State private var snatch1: String = ""
    @State private var snatch2: String = ""
    @State private var snatch3: String = ""
    @State private var cj1: String = ""
    @State private var cj2: String = ""
    @State private var cj3: String = ""
    
    @State private var squat1: String = ""
    @State private var squat2: String = ""
    @State private var squat3: String = ""
    @State private var bench1: String = ""
    @State private var bench2: String = ""
    @State private var bench3: String = ""
    @State private var deadlift1: String = ""
    @State private var deadlift2: String = ""
    @State private var deadlift3: String = ""
    
    let meetType: [String] = ["Local", "National", "International"]
    
    var hasCompletedForm: Bool {
        if snatch1.isEmpty || snatch2.isEmpty || snatch3.isEmpty || cj1.isEmpty || cj2.isEmpty || cj3.isEmpty || meet.isEmpty || didWell.isEmpty || needsWork.isEmpty || goodFromTraining.isEmpty || cues.isEmpty || focus.isEmpty {
            return false
        }
        
        return true
    }
    
    func calculateSnatchBest(snatch1: String, snatch2: String, snatch3: String) -> Int {
        return max(Int(snatch1) ?? 0, Int(snatch2) ?? 0, Int(snatch3) ?? 0)
    }
    
    func calculateCJBest(cj1: String, cj2: String, cj3: String) -> Int {
        return max(Int(cj1) ?? 0, Int(cj2) ?? 0, Int(cj3) ?? 0)
    }
    
    let iso8601String = Date.now.formatted(.iso8601)
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack{
                        Text("Which meet did you compete at?")
                            .font(.headline.bold())
                            .padding(.bottom, 6)
                        
                        TextField("Enter your meet...", text: $meet)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(blueEnergy.opacity(0.1))
                            )
                    }
                    .cardStyling()
                    
                    MultipleChoiceSection(colorScheme: colorScheme, title: "What type of meet was this?", arrayOptions: meetType, selected: $selectedMeetType)
                    
                    DatePickerSection(title: "Meet Date:", selectedDate: $meetDate)
                    
                    
                    if user.first?.sport == "Olympic Weightlifting" {
                        WLLiftResultsSection(snatch1: $snatch1, snatch2: $snatch2, snatch3: $snatch3, cj1: $cj1, cj2: $cj2, cj3: $cj3)
                    } else {
                        PLLiftResultsSection(squat1: $squat1, squat2: $squat2, squat3: $squat3, bench1: $bench1, bench2: $bench2, bench3: $bench3, deadlift1: $deadlift1, deadlift2: $deadlift2, deadlift3: $deadlift3)
                    }
                    
                    SliderSection(colorScheme: colorScheme, title: "How would you rate your performance?", value: $performanceRating, minString: "Poor", maxString: "Amazing")
                    
                    SliderSection(colorScheme: colorScheme, title: "How would you rate your preparedness?", value: $preparednessRating, minString: "Poor", maxString: "Amazing")
                    
                    TextFieldSection(field: $didWell, title: "What did you do well?", colorScheme: colorScheme, keyword: "thoughts")
                    
                    TextFieldSection(field: $needsWork, title: "What could you have done better?", colorScheme: colorScheme, keyword: "thoughts")
                    
                    TextFieldSection(field: $goodFromTraining, title: "What in training helped you feel prepared for the platform?", colorScheme: colorScheme, keyword: "thoughts")
                    
                    TextFieldSection(field: $cues, title: "What cues worked best for you?", colorScheme: colorScheme, keyword: "cues")
                    
                    TextFieldSection(field: $focus, title: "What do you need to focus on for the next meet?", colorScheme: colorScheme, keyword: "focus")
                    
                    Button {
                        let report: CompReport = CompReport(user_id: 1, meet: meet, selected_meet_type: selectedMeetType, meet_date: meetDate.formatted(.iso8601.year().month().day().dateSeparator(.dash)), performance_rating: performanceRating, preparedness_rating: preparednessRating, did_well: didWell, needs_work: needsWork, good_from_training: goodFromTraining, cues: cues, focus: focus, snatch1: snatch1, snatch2: snatch2, snatch3: snatch3, cj1: cj1, cj2: cj2, cj3: cj3, snatch_best: calculateSnatchBest(snatch1: snatch1, snatch2: snatch2, snatch3: snatch3), cj_best: calculateCJBest(cj1: cj1, cj2: cj2, cj3: cj3), created_at: iso8601String)
                        
                        Task {
                            await viewModel.submitCompReport(compReport: report)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Submit Check-In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(hasCompletedForm ? blueEnergy : .gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .disabled(!hasCompletedForm)
                }
            }
            .navigationTitle("Competition Report")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await userViewModel.fetchUsers(id: 2)
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.alertShown) {} message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

struct WLLiftResultsSection: View {
    @Binding var snatch1: String
    @Binding var snatch2: String
    @Binding var snatch3: String
    @Binding var cj1: String
    @Binding var cj2: String
    @Binding var cj3: String
    
    func bindingForSnatch(_ index: Int) -> Binding<String> {
        switch index {
        case 0: return $snatch1
        case 1: return $snatch2
        default: return $snatch3
        }
    }
    
    func bindingForCJ(_ index: Int) -> Binding<String> {
        switch index {
        case 0: return $cj1
        case 1: return $cj2
        default: return $cj3
        }
    }
    
    func calculateTotal(snatch1: String, snatch2: String, snatch3: String, cj1: String, cj2: String, cj3: String) -> Int {
        let snatchBest = max(Int(snatch1) ?? 0, Int(snatch2) ?? 0, Int(snatch3) ?? 0)
        let cjBest = max(Int(cj1) ?? 0, Int(cj2) ?? 0, Int(cj3) ?? 0)
        
        return snatchBest + cjBest
    }
    
    var body: some View {
        VStack{
            Text("What numbers did you hit?")
                .font(.headline.bold())
                .padding(.bottom, 6)
            Text("Write a miss as a negative number (ex: -115)")
                .foregroundStyle(.secondary)
            
            Text("Snatch")
                .font(.headline.bold())
                .padding(.top)
                .padding(.bottom, 6)
            
            HStack{
                ForEach(0...2, id: \.self) { num in
                    TextField("\(num + 1)", text: bindingForSnatch(num))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(blueEnergy.opacity(0.1))
                        )
                }
            }
            
            Text("Clean & Jerk")
                .font(.headline.bold())
                .padding(.top)
                .padding(.bottom, 6)
            
            HStack{
                ForEach(0...2, id: \.self) { num in
                    TextField("\(num + 1)", text: bindingForCJ(num))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(blueEnergy.opacity(0.1))
                        )
                }
            }
            
            if (calculateTotal(snatch1: snatch1, snatch2: snatch2, snatch3: snatch3, cj1: cj1, cj2: cj2, cj3: cj3) != 0) {
                Text("Total: \(calculateTotal(snatch1: snatch1, snatch2: snatch2, snatch3: snatch3, cj1: cj1, cj2: cj2, cj3: cj3))kg")
                    .font(.title3.bold())
                    .padding(.top)
                    .padding(.bottom, 6)
            }
        }
        .cardStyling()
    }
}

struct PLLiftResultsSection: View {
    @Binding var squat1: String
    @Binding var squat2: String
    @Binding var squat3: String
    @Binding var bench1: String
    @Binding var bench2: String
    @Binding var bench3: String
    @Binding var deadlift1: String
    @Binding var deadlift2: String
    @Binding var deadlift3: String
    
    func bindingForSquat(_ index: Int) -> Binding<String> {
        switch index {
        case 0: return $squat1
        case 1: return $squat2
        default: return $squat3
        }
    }
    
    func bindingForBench(_ index: Int) -> Binding<String> {
        switch index {
        case 0: return $bench1
        case 1: return $bench2
        default: return $bench3
        }
    }
    
    func bindingForDeadlift(_ index: Int) -> Binding<String> {
        switch index {
        case 0: return $deadlift1
        case 1: return $deadlift2
        default: return $deadlift3
        }
    }
    
    func calculateTotal(squat1: String, squat2: String, squat3: String, bench1: String, bench2: String, bench3: String, deadlift1: String, deadlift2: String, deadlift3: String) -> Int {
        let squatBest = max(Int(squat1) ?? 0, Int(squat2) ?? 0, Int(squat3) ?? 0)
        let benchBest = max(Int(bench1) ?? 0, Int(bench2) ?? 0, Int(bench3) ?? 0)
        let deadliftBest = max(Int(deadlift1) ?? 0, Int(deadlift2) ?? 0, Int(deadlift3) ?? 0)
        
        return squatBest + benchBest + deadliftBest
    }
    
    var body: some View {
        VStack{
            Text("What numbers did you hit?")
                .font(.headline.bold())
                .padding(.bottom, 6)
            Text("Write a miss as a negative number (ex: -115)")
                .foregroundStyle(.secondary)
            
            Text("Squat")
                .font(.headline.bold())
                .padding(.top)
                .padding(.bottom, 6)
            
            HStack{
                ForEach(0...2, id: \.self) { num in
                    TextField("\(num + 1)", text: bindingForSquat(num))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(blueEnergy.opacity(0.1))
                        )
                }
            }
            
            Text("Bench")
                .font(.headline.bold())
                .padding(.top)
                .padding(.bottom, 6)
            
            HStack{
                ForEach(0...2, id: \.self) { num in
                    TextField("\(num + 1)", text: bindingForBench(num))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(blueEnergy.opacity(0.1))
                        )
                }
            }
            
            Text("Deadlift")
                .font(.headline.bold())
                .padding(.top)
                .padding(.bottom, 6)
            
            HStack{
                ForEach(0...2, id: \.self) { num in
                    TextField("\(num + 1)", text: bindingForDeadlift(num))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(blueEnergy.opacity(0.1))
                        )
                }
            }
            
            if ((calculateTotal(squat1: squat1, squat2: squat2, squat3: squat3, bench1: bench1, bench2: bench2, bench3: bench3, deadlift1: deadlift1, deadlift2: deadlift2, deadlift3: deadlift3)) != 0) {
                Text("Total: \(calculateTotal(squat1: squat1, squat2: squat2, squat3: squat3, bench1: bench1, bench2: bench2, bench3: bench3, deadlift1: deadlift1, deadlift2: deadlift2, deadlift3: deadlift3))kg")
                    .font(.title3.bold())
                    .padding(.top)
                    .padding(.bottom, 6)
            }
        }
        .cardStyling()
    }
}

#Preview {
    CompReflectionView()
}
