//
//  MeetJournalApp.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import SwiftUI
import Clerk
import RevenueCat

@main
struct MeetJournalApp: App {
    @State private var clerk = Clerk.shared
    @State private var customerManager = CustomerInfoManager()
    var hasProAccess: Bool { customerManager.hasProAccess }
    
    let revenuecatKey = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as! String

    init() {
        Purchases.configure(withAPIKey: revenuecatKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.clerk, clerk)
                .task {
                    let clerkKey = Bundle.main.object(forInfoDictionaryKey: "CLERK_PUBLISHABLE_KEY") as! String
                    clerk.configure(publishableKey: clerkKey)
                    try? await clerk.load()
                    customerManager.setupDelegate()
                    await customerManager.fetchCustomerInfo()
                }
        }
    }
}
