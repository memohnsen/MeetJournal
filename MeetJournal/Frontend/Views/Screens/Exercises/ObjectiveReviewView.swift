import SwiftUI
import Clerk

enum ObjectiveReviewState {
    case vent
    case processing
    case reframed
}

struct ObjectiveReviewView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var ventText: String = ""
    @State private var coachReframe: String = ""
    @State private var currentState: ObjectiveReviewState = .vent
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var userSport: String = ""
    @State private var showHistory: Bool = false
    @State private var showWriteAlert: Bool = false
    @State private var breathingTextOpacity: Double = 0
    
    private let objectiveReviewService = ObjectiveReviewService()
    @State private var writeViewModel = ObjectiveReviewModel()
    @State private var usersViewModel = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack(spacing: 0) {
                        if currentState == .vent {
                            ventModeView
                        } else if currentState == .processing {
                            processingView
                        } else {
                            reframedView
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Objective Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                if !showHistory {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                ObjectiveReviewHistoryView()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert(writeViewModel.alertTitle, isPresented: $showWriteAlert) {
                Button("OK", role: .cancel) {
                    if writeViewModel.alertTitle == "Success!" {
                        resetView()
                    }
                }
            } message: {
                Text(writeViewModel.alertMessage)
            }
            .onChange(of: writeViewModel.alertShown) { _, newValue in
                showWriteAlert = newValue
            }
            .task {
                guard let userId = Clerk.shared.user?.id else { return }
                await usersViewModel.fetchUserSport(user_id: userId)
                userSport = usersViewModel.sport.first?.sport ?? "Olympic Weightlifting"
            }
        }
    }
    
    private var ventModeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What happened during that set?")
                .font(.title2.bold())
                .padding(.bottom, 4)
            
            Text("Share your honest, emotional reaction. Then let's transform it into objective coaching cues.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .padding(.bottom, 12)
            
            TextEditor(text: $ventText)
                .frame(minHeight: 200)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(blueEnergy.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(blueEnergy.opacity(0.3), lineWidth: 1)
                )
            
            Button {
                Task {
                    await processReframing()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Convert to Coach Perspective")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(canProcess ? blueEnergy : Color.gray)
                .clipShape(.rect(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .disabled(!canProcess)
            .padding(.top, 8)
        }
        .cardStyling()
    }
    
    private var processingView: some View {
        VStack(spacing: 24) {
            Text("Take a deep breath")
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .opacity(breathingTextOpacity)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: blueEnergy))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                breathingTextOpacity = 1.0
            }
        }
    }
    
    private var reframedView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Reframed Training Cues")
                    .font(.title2.bold())
                    .padding(.bottom, 4)
                
                Text("Compare your emotional reaction with the objective coaching perspective.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            .cardStyling()
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Athlete's Voice")
                        .font(.headline.bold())
                        .foregroundStyle(.secondary)
                    
                    Text(ventText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Coach's Voice")
                        .font(.headline.bold())
                        .foregroundStyle(blueEnergy)
                    
                    Text(coachReframe)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(blueEnergy.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(blueEnergy.opacity(0.5), lineWidth: 2)
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            Button {
                Task {
                    await saveToTrainingCues()
                }
            } label: {
                Text("Add to Training Cues")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(blueEnergy)
                    .clipShape(.rect(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .disabled(writeViewModel.isLoading)
            .padding(.horizontal)
        }
    }
    
    private var canProcess: Bool {
        !ventText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func processReframing() async {
        currentState = .processing
        
        do {
            let reframed = try await objectiveReviewService.reframeAthleteVent(
                ventText: ventText,
                sport: userSport
            )
            
            coachReframe = reframed
            currentState = .reframed
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            currentState = .vent
        }
    }
    
    private func saveToTrainingCues() async {
        guard let userId = Clerk.shared.user?.id else { return }
        
        let iso8601String = Date.now.formatted(.iso8601)
        
        let objectiveReview = ObjectiveReview(
            id: nil,
            user_id: userId,
            athlete_vent: ventText,
            coach_reframe: coachReframe,
            created_at: iso8601String
        )
        
        await writeViewModel.submitObjectiveReview(objectiveReview: objectiveReview)
    }
    
    private func resetView() {
        ventText = ""
        coachReframe = ""
        currentState = .vent
        breathingTextOpacity = 0
    }
}

#Preview {
    ObjectiveReviewView()
}

