//
//  ContentView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "Home"
    
    var body: some View {
        TabView(selection: $selectedTab){
            Tab("Home", systemImage: "house", value: "Home") {
                HomeView()
            }
            Tab("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90", value: "History") {
                TrendsView()
            }
            Tab("Trends", systemImage: "chart.bar", value: "Trends") {
                TrendsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
