//
//  CheckinConfirmation.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import ConfettiSwiftUI

struct CheckinConfirmation: View {
    @Bindable var checkInScore: CheckInScore
    @State private var confettiCannon: Int = 0
    
    @Binding var selectedLift: String
    @Binding var selectedIntensity: String

    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                VStack{
                    ResultsSection(checkInScore: checkInScore)
                    
                    Spacer()
                    
                    Button{
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                        Text("Send To Your Coach")
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
            .confettiCannon(trigger: $confettiCannon, num: 300, radius: 600, hapticFeedback: true)
            .onAppear {
                if checkInScore.overallScore >= 80 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        confettiCannon += 1
                    }
                }
            }
            .navigationTitle("Check-In Submitted!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ResultsSection: View {
    @Bindable var checkInScore: CheckInScore
    
    func motivationalMessage(for score: Int) -> String {
        switch score {
        case 90...100:
            return "You're crushing it!"
        case 75...89:
            return "Looking strong today!"
        case 60...74:
            return "Ready to work!"
        case 40...59:
            return "Time to dig deep today!"
        default:
            return "Consider taking today a little easier"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Your Readiness")
                .font(.title.bold())
                .padding(.top, 8)
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(blueEnergy.opacity(0.2), lineWidth: 12)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(checkInScore.overallScore) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [blueEnergy, blueEnergy.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: checkInScore.overallScore)
                    
                    VStack(spacing: 4) {
                        Text("\(checkInScore.overallScore)%")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(blueEnergy)
                    }
                }
                
                Text("Overall Readiness")
                    .font(.title3)
                    .padding(.top)
                    .foregroundStyle(.primary)
                
                Text(motivationalMessage(for: checkInScore.overallScore))
                    .font(.subheadline)
                    .foregroundStyle(blueEnergy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 32)
            
            HStack(spacing: 32) {
                // Physical Score
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(blueEnergy.opacity(0.2), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(checkInScore.physicalScore) / 100)
                            .stroke(blueEnergy, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: checkInScore.physicalScore)
                        
                        VStack(spacing: 2) {
                            Text("\(checkInScore.physicalScore)%")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(blueEnergy)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title3)
                            .foregroundStyle(blueEnergy)
                        
                        Text("Physical")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                }
                
                // Mental Score
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(blueEnergy.opacity(0.2), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(checkInScore.mentalScore) / 100)
                            .stroke(blueEnergy, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: checkInScore.mentalScore)
                        
                        VStack(spacing: 2) {
                            Text("\(checkInScore.mentalScore)%")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(blueEnergy)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Image(systemName: "brain.head.profile")
                            .font(.title3)
                            .foregroundStyle(blueEnergy)
                        
                        Text("Mental")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .cardStyling()
        .padding(.top)
    }
}

#Preview {
    struct CheckinConfirmation_PreviewContainer: View {
        @State private var checkInScore = CheckInScore()
        @State private var selectedLift: String = "Snatch"
        @State private var selectedIntensity: String = "Moderate"
        
        var body: some View {
            CheckinConfirmation(
                checkInScore: checkInScore,
                selectedLift: $selectedLift,
                selectedIntensity: $selectedIntensity
            )
        }
    }

    return CheckinConfirmation_PreviewContainer()
}
