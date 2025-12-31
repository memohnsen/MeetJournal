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
    
    @State private var userViewModel = UsersViewModel()
    var users: [Users] { userViewModel.users }
    
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
        
        await viewModel.fetchCheckinsCSV(user_id: userId)
        await viewModel.fetchCompReportsCSV(user_id: userId)
        await viewModel.fetchSessionReportCSV(user_id: userId)
        
        var combinedCSV = "=== DAILY CHECK-INS ===\n"
        combinedCSV += viewModel.checkInsCSV
        combinedCSV += "\n\n=== COMPETITION REPORTS ===\n"
        combinedCSV += viewModel.compReportCSV
        combinedCSV += "\n\n=== SESSION REPORTS ===\n"
        combinedCSV += viewModel.sessionReportCSV
        
        let tempDir = FileManager.default.temporaryDirectory
        let dateString = Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")
        let fileURL = tempDir.appendingPathComponent("MeetJournal_Export_\(dateString).csv")
        
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
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Auto-Send Results")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .cardStyling()
                        
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
                        
                        if let url = mailtoUrl {
                            Link(destination: url) {
                                HStack{
                                    Text("Submit Feedback")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .cardStyling()
                            }
                        }
                        
//                        HStack{
//                            Text("Leave a Review")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                        }
//                        .cardStyling()
                        
                        Link(destination: URL(string: "https://github.com/memohnsen/MeetJournal")!) {
                            HStack{
                                Text("Open Source Code on Github")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .cardStyling()
                        }
                        .onTapGesture {
                            AnalyticsManager.shared.trackGitHubLinkOpened()
                        }
                        
                        Text("DANGER ZONE")
                            .foregroundStyle(.red.opacity(0.75))
                            .bold()
                            .padding(.horizontal, 24)
                            .padding(.top)
                        
                        
                        Button {
                            Task {
                                await deleteViewModel.removeAllCheckIns(userId: clerk.user?.id ?? "")
                                await deleteViewModel.removeAllMeets(userId: clerk.user?.id ?? "")
                                await deleteViewModel.removeAllWorkouts(userId: clerk.user?.id ?? "")
                                AnalyticsManager.shared.trackAllDataDeleted()
                            }
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
            .task {
                await userViewModel.fetchUsers(user_id: clerk.user?.id ?? "")
                AnalyticsManager.shared.trackScreenView("SettingsView")
            }
            .alert("Data Deletion Successful", isPresented: $alertShown) {
                Button("OK") {}
            } message: {
                Text("All your data has been deleted from the database.")
            }
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
