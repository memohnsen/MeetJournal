//
//  ConnectedAppsView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 1/1/26.
//

import SwiftUI
import Clerk

struct ConnectedAppsView: View {
    @Environment(\.clerk) private var clerk
    @Environment(\.colorScheme) var colorScheme
    @State private var ouraService = Oura()
    @State private var tokenManager = OuraTokenManager()
    @State private var showOuraConnectionAlert: Bool = false
    @State private var ouraConnectionMessage: String = ""
    @State private var storeToken: Bool = false
    @State private var isLoadingToggle: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ConnectedAppRow(
                            name: "Oura",
                            icon: "circle.fill",
                            isConnected: ouraService.isAuthenticated,
                            isLoading: ouraService.isLoading,
                            onTap: {
                                Task {
                                    if ouraService.isAuthenticated {
                                        // Disconnect
                                        if let userId = clerk.user?.id {
                                            do {
                                                try await ouraService.revokeToken(userId: userId)
                                                await tokenManager.updateOuraToken(userId: userId, refreshToken: nil)
                                                ouraConnectionMessage = "Oura account disconnected successfully."
                                                showOuraConnectionAlert = true
                                            } catch {
                                                ouraConnectionMessage = "Failed to disconnect Oura account: \(error.localizedDescription)"
                                                showOuraConnectionAlert = true
                                            }
                                        }
                                    } else {
                                        // Connect
                                        do {
                                            try await ouraService.authenticate()
                                            if let userId = clerk.user?.id {
                                                await createWebhookSubscriptions(userId: userId)
                                                
                                                if storeToken {
                                                    let keychain = OuraKeychain.shared
                                                    if let refreshToken = keychain.getRefreshToken(userId: userId) {
                                                        await tokenManager.updateOuraToken(userId: userId, refreshToken: refreshToken)
                                                    }
                                                }
                                            }
                                            ouraConnectionMessage = "Oura account connected successfully!"
                                            showOuraConnectionAlert = true
                                        } catch {
                                            ouraConnectionMessage = "Failed to connect Oura account: \(error.localizedDescription)"
                                            showOuraConnectionAlert = true
                                        }
                                    }
                                }
                            }
                        )
                        
                        ConnectedAppRow(
                            name: "Whoop",
                            icon: "circle.fill",
                            isConnected: false,
                            isLoading: false,
                            isDisabled: true,
                            onTap: {}
                        )
                        
                        ConnectedAppRow(
                            name: "Apple Health",
                            icon: "circle.fill",
                            isConnected: false,
                            isLoading: false,
                            isDisabled: true,
                            onTap: {}
                        )
                        
                        Toggle("Store Data For Reports", isOn: $storeToken)
                            .cardStyling()
                            .padding(.top)
                            .onChange(of: storeToken) { oldValue, newValue in
                                Task {
                                    if let userId = clerk.user?.id {
                                        await tokenManager.updateStoreTokenPreference(userId: userId, shouldStore: newValue)
                                        
                                        if newValue {
                                            let keychain = OuraKeychain.shared
                                            if let refreshToken = keychain.getRefreshToken(userId: userId) {
                                                await tokenManager.updateOuraToken(userId: userId, refreshToken: refreshToken)
                                            }
                                        } else {
                                            await tokenManager.updateOuraToken(userId: userId, refreshToken: nil)
                                        }
                                    }
                                }
                            }
                        
                        privacyNoticeSection
                    }
                    .padding(.top)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Connected Apps")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbarVisibility(.hidden, for: .tabBar)
            .task {
                if let userId = clerk.user?.id {
                    ouraService.checkConnectionStatus(userId: userId)
                    storeToken = await tokenManager.loadToggleState(userId: userId)
                }
            }
            .alert("Oura Connection", isPresented: $showOuraConnectionAlert) {
                Button("OK") {}
            } message: {
                Text(ouraConnectionMessage)
            }
        }
    }
    
    private func createWebhookSubscriptions(userId: String) async {
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            return
        }
        
        let webhookURL = "\(supabaseURL)/functions/v1/oura-webhook"
        // Use a consistent verification token (should match what's in Supabase env or generate one)
        let verificationToken = "oura-webhook-verification-token"
        
        // According to Oura docs, we need separate subscriptions for each event_type × data_type combination
        let eventTypes = ["create", "update", "delete"]
        let dataTypes: [OuraDataType] = [.sleep, .activity, .readiness]
        
        var successCount = 0
        var failureCount = 0
        
        for eventType in eventTypes {
            for dataType in dataTypes {
                do {
                    _ = try await ouraService.createWebhookSubscription(
                        callbackURL: webhookURL,
                        verificationToken: verificationToken,
                        eventType: eventType,
                        dataType: dataType.rawValue,
                        userId: userId
                    )
                    successCount += 1
                    print("✅ Webhook subscription ready: \(eventType)/\(dataType.rawValue)")
                } catch {
                    if let ouraError = error as? OuraError,
                       case .apiError(let statusCode, _) = ouraError,
                       statusCode == 409 {
                        successCount += 1
                        print("ℹ️ Webhook subscription already exists: \(eventType)/\(dataType.rawValue)")
                    } else {
                        failureCount += 1
                        print("❌ Failed to create webhook subscription for \(eventType)/\(dataType.rawValue): \(error)")
                    }
                }
            }
        }
        
        print("📊 Webhook subscriptions: \(successCount) ready, \(failureCount) failed")
    }
    
    private var textColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    private var textColorSecondary: Color {
        colorScheme == .light ? .black.opacity(0.8) : .white.opacity(0.8)
    }
    
    private var noticeBackground: Color {
        colorScheme == .light ? Color.orange.opacity(0.1) : Color.orange.opacity(0.2)
    }
    
    private var privacyNoticeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Privacy Notice")
                    .font(.headline.bold())
                    .foregroundStyle(textColor)
            }
            
            Text("By connecting to these apps you are agreeing to letting the app access your personal data.")
                .font(.subheadline)
                .foregroundStyle(textColorSecondary)
            
            privacyBulletPoints
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(noticeBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var privacyBulletPoints: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrivacyBulletPoint(
                text: "This data is used to give deeper insights to your check-ins and reflections.",
                textColor: textColorSecondary
            )
            
            PrivacyBulletPoint(
                text: "All this data is only ever accessed on the app. It is not saved to any external database, meaning no one can see your data besides yourself and whomever you decide to share it with.",
                textColor: textColorSecondary
            )
            
            PrivacyBulletPoint(
                text: "As such, the Export Data button will include your Oura data from the date of your login to the app. However, the Auto-Send Weekly Results will NOT include this data unless you turn on the toggle allowing us to store your data.",
                textColor: textColorSecondary
            )
        }
    }
}

struct ConnectedAppRow: View {
    let name: String
    let icon: String
    let isConnected: Bool
    let isLoading: Bool
    var isDisabled: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isConnected ? .green : .secondary)
                    .frame(width: 20)
                
                Text(name)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if isDisabled {
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .disabled(isDisabled || isLoading)
        .cardStyling()
        .padding(.bottom, -6)
    }
}

#Preview {
    ConnectedAppsView()
}

