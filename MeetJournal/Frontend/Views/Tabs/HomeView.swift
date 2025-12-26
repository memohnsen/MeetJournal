//
//  HomeView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = UsersViewModel()
    var users: [Users] { viewModel.users }
    @State private var checkInScore = CheckInScore()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BackgroundColor()
                
                ScrollView {
                    VStack {
                        DailyCheckInSection(checkInScore: checkInScore)
                        
                        ReflectionSection()
                        
                        HistorySection()
                    }
                    .padding(.top, 100)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Wednesday, Oct 25")
                            .foregroundStyle(.secondary)
                        Text("Ready to train, \(users.first?.first_name ?? "")?")
                            .font(.headline.bold())
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView()) {
                        Circle()
                            .frame(width: 60)
                            .foregroundStyle(.gray)
                    }
                }
                .padding([.horizontal, .bottom])
                .padding(.top, 70)
                .glassEffect(in: .rect(cornerRadius: 32))
                .padding(.top, -70)
            }
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}

struct DailyCheckInSection: View {
    @Bindable var checkInScore: CheckInScore
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text("Today's Focus")
                        .padding(6)
                        .background(blueEnergy.opacity(0.1))
                        .foregroundStyle(blueEnergy)
                        .bold()
                        .clipShape(.rect(cornerRadius: 12))


                    Text("Daily Check-In")
                        .font(.system(size: 24))
                        .bold()
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

    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("RECENT ACTIVITY")
                    .foregroundStyle(.secondary)
                    .bold()
                    .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(destination: HistoryView()) {
                    Text("View All")
                        .bold()
                        .foregroundStyle(blueEnergy)
                }
                .padding(.trailing)
            }
            
            HStack {
                NavigationLink(destination: HistoryDetailsView()) {
                    VStack{
                        HStack{
                            VStack{
                                Text("OCT")
                                Text("23")
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.green.opacity(0.3))
                                    .frame(width: 60, height: 60)
                            )
                            .padding(.leading)
                            
                            Spacer()
                            
                            VStack{
                                Text("Heavy Snatch")
                                    .bold()
                                
                                Text("Training • Feeling Strong")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Text("9/10")
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.green.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                )
                                .padding(.trailing)
                        }
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
        .padding([.top, .horizontal])
    }
}

#Preview {
    HomeView()
}
