//
//  ContentView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Environment(\.clerk) private var clerk
    @State private var selectedTab: String = "Home"
    
    var body: some View {
        if hasSeenOnboarding && clerk.user != nil {
            TabView(selection: $selectedTab){
                Tab("Home", systemImage: "house", value: "Home") {
                    HomeView()
                }
                Tab("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90", value: "History") {
                    HistoryView()
                }
                Tab("Trends", systemImage: "chart.bar", value: "Trends") {
                    TrendsView()
                }
                Tab("Settings", systemImage: "gearshape", value: "Settings") {
                    SettingsView()
                }
            }
        } else if hasSeenOnboarding && clerk.user == nil {
            AuthView()
        } else if !hasSeenOnboarding {
            OnboardingView()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
}
