//
//  NotificationSettingsView.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/30/25.
//

import SwiftUI
import Clerk

struct NotificationSettingsView: View {
    @Environment(\.clerk) private var clerk
    @Environment(\.colorScheme) var colorScheme
    @State private var notificationManager = NotificationManager.shared
    @State private var viewModel = UserOnboardingViewModel()
    @State private var trainingDays: [String: String] = [:]
    @State private var showEditTrainingDays = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: Binding(
                                get: { notificationManager.isEnabled },
                                set: { newValue in
                                    Task {
                                        if newValue {
                                            let granted = await notificationManager.requestPermission()
                                            if granted {
                                                notificationManager.scheduleNotifications()
                                            }
                                        } else {
                                            notificationManager.isEnabled = false
                                            notificationManager.cancelAll()
                                        }
                                    }
                                }
                            )) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(notificationManager.isEnabled ? blueEnergy : .secondary)
                                    Text("Enable Notifications")
                                        .font(.headline)
                                }
                            }
                            
                            Text("Receive reminders for daily check-ins, session reflections, and competition analysis")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .cardStyling()
                        
                        if notificationManager.isEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Training Schedule")
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        showEditTrainingDays = true
                                    } label: {
                                        Text("Edit")
                                            .foregroundStyle(blueEnergy)
                                    }
                                }
                                
                                if trainingDays.isEmpty {
                                    Text("No training days set")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                } else {
                                    let sortedDays = trainingDays.keys.sorted { day1, day2 in
                                        let weekdayOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                                        let index1 = weekdayOrder.firstIndex(of: day1) ?? 999
                                        let index2 = weekdayOrder.firstIndex(of: day2) ?? 999
                                        return index1 < index2
                                    }
                                    
                                    ForEach(sortedDays, id: \.self) { day in
                                        VStack(spacing: 8) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(day)
                                                        .font(.subheadline.bold())
                                                    Text("Training at \(trainingDays[day] ?? "")")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Image(systemName: "sun.max.fill")
                                                    .foregroundStyle(.orange)
                                                    .frame(width: 20)
                                                Text("Check-in at \(trainingDays[day] ?? "")")
                                                    .font(.caption)
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Image(systemName: "figure.strengthtraining.traditional")
                                                    .foregroundStyle(blueEnergy)
                                                    .frame(width: 20)
                                                Text("Session reflection at \(calculateSessionTime(from: trainingDays[day] ?? ""))")
                                                    .font(.caption)
                                                Spacer()
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.3))
                                        )
                                    }
                                }
                            }
                            .cardStyling()
                            
                            if let meetDate = UserDefaults.standard.string(forKey: "meetDate"),
                               let meetName = UserDefaults.standard.string(forKey: "meetName") {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Competition Reminder")
                                        .font(.headline)
                                    
                                    HStack {
                                        Image(systemName: "trophy.fill")
                                            .foregroundStyle(gold)
                                            .frame(width: 20)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(meetName)
                                                .font(.subheadline.bold())
                                            Text("Notification at 5:00 PM on \(formatMeetDate(meetDate))")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.3))
                                    )
                                }
                                .cardStyling()
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Notifications")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbarVisibility(.hidden, for: .tabBar)
            .task {
                AnalyticsManager.shared.trackNotificationSettingsViewed()
                loadTrainingDays()
            }
            .sheet(isPresented: $showEditTrainingDays) {
                EditTrainingScheduleView(
                    trainingDays: $trainingDays,
                    onSave: { newTrainingDays in
                        Task {
                            await saveTrainingDays(newTrainingDays)
                        }
                        showEditTrainingDays = false
                    }
                )
            }
        }
    }
    
    private func loadTrainingDays() {
        if let jsonString = UserDefaults.standard.string(forKey: "trainingDays"),
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            trainingDays = decoded
        }
    }
    
    private func saveTrainingDays(_ newTrainingDays: [String: String]) async {
        isSaving = true
        
        // Update database
        await viewModel.updateTrainingDays(
            userId: clerk.user?.id ?? "",
            trainingDays: newTrainingDays
        )
        
        // Update AppStorage
        notificationManager.storeTrainingDays(newTrainingDays)
        
        // Reschedule notifications
        if notificationManager.isEnabled {
            notificationManager.scheduleNotifications()
        }
        
        // Reload local state
        loadTrainingDays()
        
        isSaving = false
    }
    
    private func formatMeetDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func calculateSessionTime(from timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        
        guard let date = formatter.date(from: timeString) else { return "2 hours after" }
        
        let calendar = Calendar.current
        guard let sessionTime = calendar.date(byAdding: .hour, value: 2, to: date) else { return "2 hours after" }
        
        return formatter.string(from: sessionTime)
    }
}

struct EditTrainingScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var trainingDays: [String: String]
    let onSave: ([String: String]) -> Void
    
    @State private var editableTrainingDays: [String: String] = [:]
    @State private var showingTimePicker: String? = nil
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let timeOptions = [
        "4:00 AM", "5:00 AM", "6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM"
    ]
    
    func isDaySelected(_ day: String) -> Bool {
        return editableTrainingDays[day] != nil
    }
    
    func selectedDayColor(_ day: String) -> Color {
        return isDaySelected(day) ? blueEnergy : blueEnergy.opacity(0.2)
    }
    
    func selectedDayTextColor(_ day: String) -> Color {
        return isDaySelected(day) ? .white : .blue
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack {
                        Text("When do you train?")
                            .font(.headline.bold())
                            .padding(.bottom)
                        
                        ForEach(daysOfWeek, id: \.self) { day in
                            HStack(spacing: 16) {
                                Button {
                                    if isDaySelected(day) {
                                        editableTrainingDays.removeValue(forKey: day)
                                        showingTimePicker = nil
                                    } else {
                                        editableTrainingDays[day] = timeOptions[0]
                                    }
                                } label: {
                                    Text(day)
                                        .frame(width: 120)
                                        .padding()
                                        .background(selectedDayColor(day))
                                        .clipShape(.capsule)
                                        .foregroundStyle(selectedDayTextColor(day))
                                        .bold()
                                }
                                
                                if isDaySelected(day) {
                                    Button {
                                        showingTimePicker = day
                                    } label: {
                                        Text(editableTrainingDays[day] ?? timeOptions[0])
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(blueEnergy.opacity(0.2))
                                            .clipShape(.capsule)
                                            .foregroundStyle(.blue)
                                            .bold()
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { showingTimePicker == day },
                                        set: { if !$0 { showingTimePicker = nil } }
                                    )) {
                                        VStack {
                                            Text("Select Time")
                                                .font(.headline)
                                                .padding()
                                            
                                            Picker("Time", selection: Binding(
                                                get: { editableTrainingDays[day] ?? timeOptions[0] },
                                                set: { editableTrainingDays[day] = $0 }
                                            )) {
                                                ForEach(timeOptions, id: \.self) { time in
                                                    Text(time).tag(time)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .padding()
                                            
                                            Button("Done") {
                                                showingTimePicker = nil
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .bold()
                                            .clipShape(.rect(cornerRadius: 12))
                                            .padding()
                                        }
                                        .presentationDetents([.height(350)])
                                    }
                                } else {
                                    Text("Select time")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(.capsule)
                                        .foregroundStyle(.gray)
                                        .bold()
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
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
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Edit Training Days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, *) {
                        Button("Save", role: .confirm) {
                            onSave(editableTrainingDays)
                            dismiss()
                        }
                    } else {
                        Button("Save") {
                            onSave(editableTrainingDays)
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            editableTrainingDays = trainingDays
        }
    }
}

#Preview {
    NotificationSettingsView()
}
