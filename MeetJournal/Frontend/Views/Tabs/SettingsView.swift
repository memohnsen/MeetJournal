//
//  SettingsView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/26/25.
//

import SwiftUI
import RevenueCatUI
import RevenueCat
import Clerk

struct SettingsView: View {
    @Environment(\.clerk) private var clerk
    @State private var showCustomerCenter: Bool = false
    @State private var viewModel = HistoryModel()
    @State private var csvFileURL: URL?
    @State private var showShareSheet = false
    @State private var isExporting = false
    
    @State private var deleteViewModel = RemoveAllModel()
    @State private var alertShown: Bool = false
    @State private var alertDeletedShown: Bool = false
    
    @State private var userViewModel = UsersViewModel()
    var users: [Users] { userViewModel.users }
    
    @State private var showCoachEmailSheet: Bool = false
    @State private var coachEmailManager = CoachEmailManager()
    @State private var showCoachEmailSavedAlert: Bool = false
    @State private var ouraService = Oura()
    @State private var whoopService = Whoop()
        
    let device = UIDevice.current
    
    let recipient: String = "maddisen@meetcal.app"
    let subject: String = "Forge - Performance Journal Feedback"
    var emailBody: String { "Hello, my name is \(users.first?.first_name ?? "") \(users.first?.last_name ?? "").\n\nMy User ID is: \(clerk.user?.id ?? "").\n\nMy Purchase ID is: \(Purchases.shared.appUserID)\n\nMy device and iOS version are: \(device.name) \(device.model) \(device.systemName) \(device.systemVersion)" }
    
    var encodedSubject: String? {
        subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    var encodedBody: String? {
        emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "%0A", with: "%0D%0A")
    }

    var mailtoUrl: URL? {
        if let encodedSubject = encodedSubject, let encodedBody = encodedBody {
            return URL(string: "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)")
        }
        return nil
    }
    
    var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    func createCSVFile() async -> URL? {
        guard let userId = clerk.user?.id else { return nil }
        
        await userViewModel.fetchUsers(user_id: userId)
        
        await viewModel.fetchCheckinsCSV(user_id: userId)
        await viewModel.fetchCompReportsCSV(user_id: userId)
        await viewModel.fetchSessionReportCSV(user_id: userId)
        
        var startDate: Date? = nil
        if let user = userViewModel.users.first, let createdAtString = user.created_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            startDate = dateFormatter.date(from: createdAtString)
        }
        
        if startDate == nil {
            let calendar = Calendar.current
            startDate = calendar.date(byAdding: .year, value: -1, to: Date())
        }
        
        if ouraService.getAccessToken(userId: userId) != nil, let ouraStartDate = startDate {
            await viewModel.fetchOuraDataCSV(userId: userId, startDate: ouraStartDate)
        }
        
        if whoopService.getAccessToken(userId: userId) != nil, let whoopStartDate = startDate {
            await viewModel.fetchWhoopDataCSV(userId: userId, startDate: whoopStartDate)
        }
        
        var combinedCSV = "=== DAILY CHECK-INS ===\n"
        combinedCSV += viewModel.checkInsCSV
        combinedCSV += "\n\n=== COMPETITION REPORTS ===\n"
        combinedCSV += viewModel.compReportCSV
        combinedCSV += "\n\n=== SESSION REPORTS ===\n"
        combinedCSV += viewModel.sessionReportCSV
        
        if !viewModel.ouraDataCSV.isEmpty {
            combinedCSV += "\n\n=== OURA DATA ===\n"
            combinedCSV += viewModel.ouraDataCSV
        }
        
        if !viewModel.whoopDataCSV.isEmpty {
            combinedCSV += "\n\n=== WHOOP DATA ===\n"
            combinedCSV += viewModel.whoopDataCSV
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let dateString = Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")
        let fileURL = tempDir.appendingPathComponent("Forge_Export_\(dateString).csv")
        
        do {
            try combinedCSV.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating CSV file: \(error)")
            return nil
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(alignment: .leading) {
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Text("Notifications")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        .padding(.bottom, -6)
                        
                        NavigationLink(destination: ConnectedAppsView()) {
                            HStack {
                                Text("Connected Apps")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        .padding(.bottom, -6)
                        
                        Button {
                            isExporting = true
                            Task {
                                if let fileURL = await createCSVFile() {
                                    csvFileURL = fileURL
                                    showShareSheet = true
                                }
                                isExporting = false
                            }
                        } label: {
                            HStack {
                                Text(isExporting ? "Exporting Data..." : "Export My Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .disabled(isExporting)
                        .cardStyling()
                        .padding(.bottom, -6)
                        
                        Button {
                            showCoachEmailSheet = true
                        } label: {
                            HStack {
                                Text("Auto-Send Results")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        .padding(.bottom, -6)
                        
                        Button{
                            showCustomerCenter = true
                            AnalyticsManager.shared.trackCustomerCenterViewed()
                        } label: {
                            HStack{
                                Text("Customer Support")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        .padding(.bottom, -6)
                        
                        if let url = mailtoUrl {
                            Link(destination: url) {
                                HStack{
                                    Text("Submit Feedback")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .cardStyling()
                                .padding(.bottom, -6)
                            }
                        }
                        
//                        HStack{
//                            Text("Leave a Review")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                        }
//                        .cardStyling()
                        
                        Text("DANGER ZONE")
                            .foregroundStyle(.red.opacity(0.75))
                            .bold()
                            .padding(.horizontal, 24)
                            .padding(.top)
                        
                        
                        Button {
                            alertShown = true
                        } label: {
                            HStack{
                                Text("Delete All Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(.red)
                            .cardStyling()
                        }
                        
                        VStack {
                            HStack {
                                Spacer()
                                Link("Privacy Policy", destination: URL(string: "https://www.meetcal.app/forge-privacy")!)
                                Text("•")
                                Link("Terms of Use", destination: URL(string: "https://www.meetcal.app/forge-terms")!)
                                Text("•")
                                Link("User Agreement", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                Spacer()
                            }
                            
                            Text("Forge Version: \(appVersion ?? "1.0.0")")
                                .foregroundStyle(.secondary)
                                .padding(.top)
                        }
                        .font(.system(size: 14))
                        .padding(.top)
                    }
                    .padding(.top)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let fileURL = csvFileURL {
                    ShareSheet(items: [fileURL])
                }
            }
            .sheet(isPresented: $showCoachEmailSheet) {
                CoachEmailSheet(
                    coachEmail: users.first?.coach_email ?? "",
                    onSave: { email in
                        Task {
                            if let userId = clerk.user?.id {
                                await coachEmailManager.updateCoachEmail(
                                    userId: userId,
                                    email: email.isEmpty ? nil : email
                                )
                                // Refresh user data to get updated coach_email
                                await userViewModel.fetchUsers(user_id: userId)
                                showCoachEmailSavedAlert = true
                            }
                        }
                        showCoachEmailSheet = false
                    },
                    onCancel: {
                        showCoachEmailSheet = false
                    }
                )
                .presentationDetents([.fraction(0.7)])
            }
            .task {
                await userViewModel.fetchUsers(user_id: clerk.user?.id ?? "")
                AnalyticsManager.shared.trackScreenView("SettingsView")
            }
            .alert("Coach Email Saved", isPresented: $showCoachEmailSavedAlert) {
                Button("OK") {}
            } message: {
                Text("Your coach email has been saved. Weekly reports will be sent automatically every Sunday.")
            }
            .alert("Are you sure you want to delete all your data?", isPresented: $alertShown) {
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteViewModel.removeAllCheckIns(userId: clerk.user?.id ?? "")
                        await deleteViewModel.removeAllMeets(userId: clerk.user?.id ?? "")
                        await deleteViewModel.removeAllWorkouts(userId: clerk.user?.id ?? "")
                        AnalyticsManager.shared.trackAllDataDeleted()
                    }
                    alertDeletedShown = true
                }
            } message: {
                Text("There is no way to recover this.")
            }
            .alert("Deletion Successfull", isPresented: $alertDeletedShown) {
                Button("OK") {}
            } message: {
                Text("All your data has been deleted.")
            }
        }
    }
}

struct CoachEmailSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var emailText: String
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    init(coachEmail: String, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        _emailText = State(initialValue: coachEmail)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    private var textColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    private var textColorSecondary: Color {
        colorScheme == .light ? .black.opacity(0.8) : .white.opacity(0.8)
    }
    
    private var fieldBackground: Color {
        colorScheme == .light ? Color.white.opacity(0.6) : Color.black.opacity(0.2)
    }
    
    private var noticeBackground: Color {
        colorScheme == .light ? Color.orange.opacity(0.1) : Color.orange.opacity(0.2)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleSave() {
        let trimmedEmail = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            onSave("")
            return
        }
        
        if !isValidEmail(trimmedEmail) {
            showError = true
            errorMessage = "Please enter a valid email address"
            return
        }
        
        onSave(trimmedEmail)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        emailInputSection
                        privacyNoticeSection
                        Spacer()
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Auto-Send Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        showError = false
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, *) {
                        Button("Save", role: .confirm) {
                            showError = false
                            handleSave()
                        }
                        .fontWeight(.semibold)
                    } else {
                        Button("Save") {
                            showError = false
                            handleSave()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coach Email Address")
                .font(.headline.bold())
                .foregroundStyle(textColor)
            
            TextField("coach@example.com", text: $emailText)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(fieldBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showError ? Color.red : Color.clear, lineWidth: 1)
                )
            
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal)
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
            
            Text("By entering a coach email address, you acknowledge and accept that:")
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
    }
    
    private var privacyBulletPoints: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrivacyBulletPoint(
                text: "Your private performance data (check-ins, competition reports, and session reports) and wearable data (Oura/Whoop if you have agreed to store this) will be automatically shared with the email address you provide.",
                textColor: textColorSecondary
            )
            
            PrivacyBulletPoint(
                text: "Data will be sent weekly on Sunday morning via email.",
                textColor: textColorSecondary
            )
            
            PrivacyBulletPoint(
                text: "You are responsible for ensuring the email address is correct and that the recipient is authorized to receive your data.",
                textColor: textColorSecondary
            )
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
