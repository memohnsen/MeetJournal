//
//  CheckInView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var checkInScore: CheckInScore
    @State private var selectedLift: String = "Snatch"
    @State private var selectedIntensity: String = "Moderate"
    
    let liftOptions: [String] = [
        "Snatch", "Clean", "Jerk", "C & J", "Total", "Squats", "Accessories", "Other"
    ]
    
    let intensityOptions: [String] = ["Maxing Out", "Heavy", "Moderate", "Light"]
    
    var body: some View {
        ZStack{
            BackgroundColor()
                
                ScrollView{
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the main focus?",
                        arrayOptions: liftOptions,
                        selected: $selectedLift
                    )
                    
                    MultipleChoiceSection(
                        colorScheme: colorScheme,
                        title: "What's the intensity?",
                        arrayOptions: intensityOptions,
                        selected: $selectedIntensity
                    )
                    
                    GoalSection(
                        goal: $checkInScore.goal,
                        title: "What's your goal for this session?",
                        colorScheme: colorScheme
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How physically strong do you feel?",
                        value: $checkInScore.physicalStrength,
                        minString: "Weak",
                        maxString: "Strong"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How mentally strong do you feel?",
                        value: $checkInScore.mentalStrength,
                        minString: "Weak",
                        maxString: "Strong"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How recovered do you feel?",
                        value: $checkInScore.recovered,
                        minString: "Not At All",
                        maxString: "Very"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "How confident do you feel?",
                        value: $checkInScore.confidence,
                        minString: "Not At All",
                        maxString: "Very"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate last night's sleep",
                        value: $checkInScore.sleep,
                        minString: "Poor",
                        maxString: "Great"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your energy",
                        value: $checkInScore.energy,
                        minString: "Low",
                        maxString: "High"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your stress",
                        value: $checkInScore.stress,
                        minString: "Extreme",
                        maxString: "Relaxed"
                    )
                    
                    SliderSection(
                        colorScheme: colorScheme,
                        title: "Rate your soreness",
                        value: $checkInScore.soreness,
                        minString: "Extreme",
                        maxString: "None"
                    )
                    
                    NavigationLink(destination: CheckinConfirmation(checkInScore: $checkInScore, selectedLift: $selectedLift, selectedIntensity: $selectedIntensity)) {
                        Text("Submit Check-In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(blueEnergy)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MultipleChoiceSection: View {
    var colorScheme: ColorScheme
    var title: String
    var arrayOptions: [String]
    @Binding var selected: String
    
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
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding(.bottom)
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(arrayOptions, id: \.self) { option in
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
                }
                .padding([.bottom, .horizontal])
            }
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
    }
}

struct SliderSection: View {
    var colorScheme: ColorScheme
    var title: String
    @Binding var value: Int
    var minString: String
    var maxString: String
    
    @State private var dragOffset: CGFloat = 0
    @State private var lineWidth: CGFloat = 0
    
    let minValue = 1
    let maxValue = 5
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline.bold())
            
            Text("\(value)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(blueEnergy)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(blueEnergy.opacity(0.2))
                        .frame(height: 8)
                    
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { position in
                            Circle()
                                .fill(value == position ? blueEnergy : blueEnergy.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            if position < 5 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Circle()
                        .fill(blueEnergy)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .offset(x: circlePosition(in: geometry.size.width))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    let totalWidth = geometry.size.width - 40
                                    let newOffset = gesture.location.x - 20
                                    dragOffset = min(max(newOffset, 0), totalWidth)
                                    
                                    let segmentWidth = totalWidth / CGFloat(maxValue - minValue)
                                    let newValue = Int(round(dragOffset / segmentWidth)) + minValue
                                    value = min(max(newValue, minValue), maxValue)
                                }
                                .onEnded { _ in
                                    dragOffset = 0
                                }
                        )
                }
                .frame(height: 40)
                .onAppear {
                    lineWidth = geometry.size.width
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 20)
            
            HStack {
                Text(minString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(maxString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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
    }
    
    private func circlePosition(in width: CGFloat) -> CGFloat {
        let totalWidth = width - 40
        let segmentWidth = totalWidth / CGFloat(maxValue - minValue)
        return CGFloat(value - minValue) * segmentWidth
    }
}

struct GoalSection: View {
    @Binding var goal: String
    var title: String
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack{
            Text(title)
                .font(.headline.bold())
                .padding(.bottom)
            
            TextField("Enter your goal...", text: $goal, axis: .vertical)
                .padding()
                .frame(height: 120, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(blueEnergy.opacity(0.1))
                )
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
    }
}

#Preview {
    struct CheckInView_PreviewContainer: View {
        @State private var checkInScore = CheckInScore()
        
        var body: some View {
            CheckInView(checkInScore: $checkInScore)
        }
    }
    
    return CheckInView_PreviewContainer()
}
