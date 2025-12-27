//
//  MeetJournalApp.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk

@main
struct MeetJournalApp: App {
    @State private var clerk = Clerk.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.clerk, clerk)
                .task {
                    let clerkKey = Bundle.main.object(forInfoDictionaryKey: "CLERK_PUBLISHABLE_KEY") as! String
                    clerk.configure(publishableKey: clerkKey)
                    try? await clerk.load()
                }
        }
    }
}
