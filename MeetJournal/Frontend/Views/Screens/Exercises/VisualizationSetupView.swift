import SwiftUI
import Clerk

struct VisualizationSetupView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var movement: String = ""
    @State private var cues: String = ""
    @State private var selectedVoice: VoiceOption = .matilda
    @State private var isPlayerActive: Bool = false
    @State private var isGenerating: Bool = false
    @State private var generatedAudioData: Data?
    @State private var generatedScript: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var useCachedVersion: Bool = false
    @State private var hasCachedVersion: Bool = false
    @State private var userSport: String = "athlete"
    
    private let visualizationService = VisualizationService()
    private let cache = VisualizationCache.shared
    private let usersViewModel = UsersViewModel()
        
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                if isPlayerActive, let audioData = generatedAudioData {
                    VisualizationPlayerView(
                        audioData: audioData,
                        script: generatedScript,
                        movement: movement,
                        onComplete: {
                            isPlayerActive = false
                        }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Visualization Setup")
                                    .font(.title2.bold())
                                    .padding(.bottom, 4)
                                
                                Text("Describe your movement and the cues you want to focus on. A personalized guided visualization will be generated to help you mentally prepare. This could take up to 30s to generate, please don't leave the page after clicking generate.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(4)
                            }
                            .cardStyling()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Enter your movement & weight")
                                    .font(.headline.bold())
                                
                                TextField("e.g., 200kg Squat, 100kg Snatch", text: $movement)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(blueEnergy.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(blueEnergy.opacity(0.3), lineWidth: 1)
                                    )
                                    .onChange(of: movement) { _, _ in
                                        checkForCachedVersion()
                                    }
                            }
                            .cardStyling()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What do you want to focus on?")
                                    .font(.headline.bold())
                                
                                TextEditor(text: $cues)
                                    .frame(minHeight: 100)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(blueEnergy.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(blueEnergy.opacity(0.3), lineWidth: 1)
                                    )
                                    .onChange(of: cues) { _, _ in
                                        checkForCachedVersion()
                                    }
                            }
                            .cardStyling()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Voice")
                                    .font(.headline.bold())
                                
                                HStack(spacing: 10) {
                                    ForEach(VoiceOption.allCases) { voice in
                                        VoiceOptionButton(
                                            voice: voice,
                                            isSelected: selectedVoice == voice,
                                            action: {
                                                selectedVoice = voice
                                                checkForCachedVersion()
                                            }
                                        )
                                    }
                                }
                            }
                            .cardStyling()
                            
                            if hasCachedVersion {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .foregroundStyle(.green)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Saved Version Available")
                                            .font(.subheadline.bold())
                                        Text("Play without using API credits")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $useCachedVersion)
                                        .labelsHidden()
                                        .tint(blueEnergy)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
                            
                            Button {
                                Task {
                                    await generateVisualization()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if isGenerating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text(visualizationService.isGeneratingScript ? "Generating Script..." : "Creating Audio...")
                                    } else {
                                        Image(systemName: "waveform")
                                        Text(useCachedVersion ? "Play Saved Visualization" : "Generate Visualization")
                                    }
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(.white)
                                .background(canGenerate ? blueEnergy : Color.gray)
                                .clipShape(.rect(cornerRadius: 12))
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                            .disabled(!canGenerate || isGenerating)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Visualization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadUserSport()
            }
        }
    }
    
    private var canGenerate: Bool {
        !movement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !cues.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadUserSport() async {
        guard let userId = Clerk.shared.user?.id else { return }
        await usersViewModel.fetchUsers(user_id: userId)
        if let user = usersViewModel.users.first {
            userSport = user.sport
        }
    }
    
    private func checkForCachedVersion() {
        let key = cache.cacheKey(movement: movement, cues: cues, voice: selectedVoice)
        hasCachedVersion = cache.hasCachedAudio(key: key)
        if !hasCachedVersion {
            useCachedVersion = false
        }
    }
    
    private func generateVisualization() async {
        isGenerating = true
        
        let key = cache.cacheKey(movement: movement, cues: cues, voice: selectedVoice)
        
        if useCachedVersion, let cachedAudio = cache.loadAudio(key: key) {
            generatedAudioData = cachedAudio
            generatedScript = cache.loadScript(key: key) ?? ""
            isGenerating = false
            isPlayerActive = true
            
            AnalyticsManager.shared.trackVisualizationGenerated(
                movement: movement,
                cuesLength: cues.count,
                voice: selectedVoice.name,
                sport: userSport,
                cached: true,
                success: true
            )
            
            return
        }
        
        do {
            let (script, audio) = try await visualizationService.generateVisualization(
                movement: movement,
                cues: cues,
                sport: userSport,
                voice: selectedVoice
            )
            
            try? cache.saveAudio(audio, key: key)
            try? cache.saveScript(script, key: key)
            
            generatedScript = script
            generatedAudioData = audio
            isGenerating = false
            isPlayerActive = true
            
        } catch {
            isGenerating = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct VoiceOptionButton: View {
    let voice: VoiceOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "person.wave.2")
                    .font(.title2)
                
                Text(voice.name)
                    .font(.subheadline.bold())
                
                Text(voice.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? blueEnergy.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? blueEnergy : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .foregroundStyle(isSelected ? blueEnergy : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VisualizationSetupView()
}
