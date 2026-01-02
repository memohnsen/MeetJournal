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
    @State private var ouraTokenManager = OuraTokenManager()
    @State private var whoopService = Whoop()
    @State private var whoopTokenManager = WhoopTokenManager()
    @State private var showOuraConnectionAlert: Bool = false
    @State private var ouraConnectionMessage: String = ""
    @State private var showWhoopConnectionAlert: Bool = false
    @State private var whoopConnectionMessage: String = ""
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
                                                await ouraTokenManager.updateOuraToken(userId: userId, refreshToken: nil)
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
                                                        await ouraTokenManager.updateOuraToken(userId: userId, refreshToken: refreshToken)
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
                            isConnected: whoopService.isAuthenticated,
                            isLoading: whoopService.isLoading,
                            onTap: {
                                Task {
                                    print("🔔 [ConnectedAppsView] WHOOP connection tapped")
                                    if whoopService.isAuthenticated {
                                        // Disconnect
                                        print("🔔 [ConnectedAppsView] Disconnecting WHOOP")
                                        if let userId = clerk.user?.id {
                                            do {
                                                try await whoopService.revokeToken(userId: userId)
                                                await whoopTokenManager.updateWhoopToken(userId: userId, refreshToken: nil)
                                                whoopConnectionMessage = "WHOOP account disconnected successfully."
                                                showWhoopConnectionAlert = true
                                                print("✅ [ConnectedAppsView] WHOOP disconnected successfully")
                                            } catch {
                                                whoopConnectionMessage = "Failed to disconnect WHOOP account: \(error.localizedDescription)"
                                                showWhoopConnectionAlert = true
                                                print("❌ [ConnectedAppsView] WHOOP disconnect failed: \(error.localizedDescription)")
                                            }
                                        }
                                    } else {
                                        // Connect
                                        print("🔔 [ConnectedAppsView] Connecting WHOOP")
                                        do {
                                            try await whoopService.authenticate()
                                            if let userId = clerk.user?.id {
                                                // Note: WHOOP webhooks are configured in the WHOOP Developer Dashboard,
                                                // not via API. See: https://developer.whoop.com/docs/developing/webhooks/                                                
                                                try await Task.sleep(nanoseconds: 100_000_000) 
                                                
                                                if storeToken {
                                                    print("💾 [ConnectedAppsView] storeToken is true, saving WHOOP refresh token")
                                                    let keychain = WhoopKeychain.shared
                                                    
                                                    var refreshToken: String? = nil
                                                    for attempt in 1...3 {
                                                        refreshToken = keychain.getRefreshToken(userId: userId)
                                                        if refreshToken != nil {
                                                            print("✅ [ConnectedAppsView] Found refresh token in keychain on attempt \(attempt)")
                                                            break
                                                        }
                                                        if attempt < 3 {
                                                            print("⚠️ [ConnectedAppsView] Refresh token not found, retrying... (attempt \(attempt))")
                                                            try await Task.sleep(nanoseconds: 100_000_000)
                                                        }
                                                    }
                                                    
                                                    if let refreshToken = refreshToken {
                                                        print("💾 [ConnectedAppsView] Saving refresh token to database (length: \(refreshToken.count))")
                                                        await whoopTokenManager.updateWhoopToken(userId: userId, refreshToken: refreshToken)
                                                        print("✅ [ConnectedAppsView] WHOOP refresh token saved to database")
                                                    } else {
                                                        print("⚠️ [ConnectedAppsView] No WHOOP refresh token found in keychain after multiple attempts")
                                                        print("⚠️ [ConnectedAppsView] This might indicate:")
                                                        print("⚠️ [ConnectedAppsView] 1. WHOOP didn't return a refresh token in the token exchange")
                                                        print("⚠️ [ConnectedAppsView] 2. The refresh token wasn't saved to keychain properly")
                                                        print("⚠️ [ConnectedAppsView] 3. WHOOP requires 'offline' scope for refresh tokens (not available in their scope list)")
                                                    }
                                                } else {
                                                    print("ℹ️ [ConnectedAppsView] storeToken is false, not saving WHOOP refresh token")
                                                }
                                            }
                                            whoopConnectionMessage = "WHOOP account connected successfully!"
                                            showWhoopConnectionAlert = true
                                            print("✅ [ConnectedAppsView] WHOOP connected successfully")
                                        } catch {
                                            whoopConnectionMessage = "Failed to connect WHOOP account: \(error.localizedDescription)"
                                            showWhoopConnectionAlert = true
                                            print("❌ [ConnectedAppsView] WHOOP connection failed: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        )
                        
                        Toggle("Store Data For Reports", isOn: $storeToken)
                            .cardStyling()
                            .padding(.top)
                            .onChange(of: storeToken) { oldValue, newValue in
                                Task {
                                    print("🔄 [ConnectedAppsView] Store token toggle changed: \(newValue)")
                                    if let userId = clerk.user?.id {
                                        await ouraTokenManager.updateStoreTokenPreference(userId: userId, shouldStore: newValue)
                                        
                                        if newValue {
                                            print("💾 [ConnectedAppsView] Saving tokens for both services")
                                            let ouraKeychain = OuraKeychain.shared
                                            if let ouraRefreshToken = ouraKeychain.getRefreshToken(userId: userId) {
                                                await ouraTokenManager.updateOuraToken(userId: userId, refreshToken: ouraRefreshToken)
                                                print("✅ [ConnectedAppsView] Oura refresh token saved")
                                            } else {
                                                print("ℹ️ [ConnectedAppsView] No Oura refresh token to save")
                                            }
                                            
                                            let whoopKeychain = WhoopKeychain.shared
                                            if let whoopRefreshToken = whoopKeychain.getRefreshToken(userId: userId) {
                                                await whoopTokenManager.updateWhoopToken(userId: userId, refreshToken: whoopRefreshToken)
                                                print("✅ [ConnectedAppsView] WHOOP refresh token saved")
                                            } else {
                                                print("ℹ️ [ConnectedAppsView] No WHOOP refresh token to save")
                                            }
                                        } else {
                                            print("🗑️ [ConnectedAppsView] Clearing tokens for both services")
                                            await ouraTokenManager.updateOuraToken(userId: userId, refreshToken: nil)
                                            await whoopTokenManager.updateWhoopToken(userId: userId, refreshToken: nil)
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
                print("🚀 [ConnectedAppsView] View appeared, checking connection status")
                if let userId = clerk.user?.id {
                    print("👤 [ConnectedAppsView] User ID: \(userId)")
                    ouraService.checkConnectionStatus(userId: userId)
                    whoopService.checkConnectionStatus(userId: userId)
                    storeToken = await ouraTokenManager.loadToggleState(userId: userId)
                    print("💾 [ConnectedAppsView] Store token state: \(storeToken)")
                }
            }
            .alert("Oura Connection", isPresented: $showOuraConnectionAlert) {
                Button("OK") {}
            } message: {
                Text(ouraConnectionMessage)
            }
            .alert("WHOOP Connection", isPresented: $showWhoopConnectionAlert) {
                Button("OK") {}
            } message: {
                Text(whoopConnectionMessage)
            }
        }
    }
    
    private func createWebhookSubscriptions(userId: String) async {
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            return
        }
        
        let webhookURL = "\(supabaseURL)/functions/v1/oura-webhook"
        let verificationToken = "oura-webhook-verification-token"
        
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
        
        print("📊 [ConnectedAppsView] Oura webhook subscriptions: \(successCount) ready, \(failureCount) failed")
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
                text: "As such, the Export Data button will include your Oura and WHOOP data from the date of your login to the app. However, the Auto-Send Weekly Results will NOT include this data unless you turn on the toggle allowing us to store your data.",
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

