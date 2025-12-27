//
//  ContentView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk
import RevenueCatUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Environment(\.clerk) private var clerk
    @State private var customerManager = CustomerInfoManager()
    @State private var selectedTab: String = "Home"
    @State private var showPaywall: Bool = false
    @State private var onboardingData = OnboardingData()
    
    var body: some View {
        Group {
            // Hasn't completed onboarding yet
            if !hasSeenOnboarding {
                OnboardingView(onboardingData: onboardingData)
                    .environment(customerManager)
            
            // Logged out (show auth first)
            } else if clerk.user == nil {
                AuthView()
            
            // Logged in + has subscription = show tabs
            } else if customerManager.hasProAccess {
                mainTabView
            
            // Logged in + no subscription = show paywall
            } else {
                Color.clear
                    .onAppear {
                        showPaywall = true
                    }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .onPurchaseCompleted { _ in
                    Task {
                        await customerManager.fetchCustomerInfo()
                    }
                    showPaywall = false
                }
                .onRestoreCompleted { _ in
                    Task {
                        await customerManager.fetchCustomerInfo()
                    }
                    showPaywall = false
                }
        }
        .task {
            customerManager.setupDelegate()
            if clerk.user != nil {
                await customerManager.fetchCustomerInfo()
            }
        }
        .onChange(of: customerManager.hasProAccess) { _, newValue in
            if newValue {
                showPaywall = false
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: "Home") {
                HomeView(onboardingData: onboardingData)
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
    }
}

#Preview {
    ContentView()
}
