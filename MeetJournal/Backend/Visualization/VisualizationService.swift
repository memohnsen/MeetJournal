import Foundation
import Clerk

@Observable
class VisualizationService {
    private let openRouter = OpenRouter()
    private let elevenLabs = ElevenLabs()
    
    var isGeneratingScript: Bool = false
    var isGeneratingAudio: Bool = false
    var generatedScript: String = ""
    var error: String?
    
    var isLoading: Bool {
        isGeneratingScript || isGeneratingAudio
    }
    
    func generateScript(movement: String, cues: String, sport: String) async throws -> String {
        isGeneratingScript = true
        error = nil
        defer { isGeneratingScript = false }
        
        let prompt = buildVisualizationPrompt(movement: movement, cues: cues, sport: sport)
        
        do {
            let script = try await openRouter.query(prompt: prompt, purpose: "visualization_script")
            generatedScript = script
            return script
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func generateAudio(script: String, voice: VoiceOption) async throws -> Data {
        isGeneratingAudio = true
        error = nil
        defer { isGeneratingAudio = false }
        
        do {
            let audioData = try await elevenLabs.textToSpeech(
                text: script,
                voice: voice,
                stability: 0.6,
                similarityBoost: 0.8
            )
            return audioData
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func generateVisualization(movement: String, cues: String, sport: String, voice: VoiceOption) async throws -> (script: String, audio: Data) {
        do {
            let script = try await generateScript(movement: movement, cues: cues, sport: sport)
            let audio = try await generateAudio(script: script, voice: voice)
            
            AnalyticsManager.shared.trackVisualizationGenerated(
                movement: movement,
                cuesLength: cues.count,
                voice: voice.name,
                sport: sport,
                cached: false,
                success: true
            )
            
            return (script, audio)
        } catch {
            AnalyticsManager.shared.trackVisualizationGenerated(
                movement: movement,
                cuesLength: cues.count,
                voice: voice.name,
                sport: sport,
                cached: false,
                success: false
            )
            throw error
        }
    }
    
    private func buildVisualizationPrompt(movement: String, cues: String, sport: String) -> String {
        """
        You are a professional \(sport) coach creating a guided visualization script for an athlete preparing for a movement.
        
        The athlete wants to visualize: \(movement)
        Their personal cues to focus on: \(cues)
        
        Create a calming, focused visualization script that:
        1. Starts by having them close their eyes and take deep breaths
        2. Guides them to visualize approaching and setting up for the movement
        3. Walks through the setup phase incorporating their specific cues
        4. Describes the execution with vivid sensory detail
        5. Emphasizes feeling strong, confident, and in control
        6. Ends with successfully completing the movement and the feeling of accomplishment
        
        Tone:
        - Sound confident, but not robotic. Remember you're speaking to a person.
        
        IMPORTANT FORMATTING RULES:
        - Include <break time="3.0s" /> tags between major steps to give the athlete time to visualize
        - Use <break time="2.0s" /> for shorter pauses between sentences within a section
        - Use <break time="1.0s" /> for brief pauses for emphasis
        - Keep the total script around 2-3 minutes when read aloud
        - Use second person ("you") to speak directly to the athlete
        - Keep sentences short and easy to follow
        - Use a calm, confident, encouraging tone
        
        Example pacing:
        "Close your eyes and take a deep breath in... <break time="2.0s" /> And slowly release. <break time="2.0s" /> Feel your body becoming calm and focused. <break time="3.0s" />"
        
        Generate only the script text, no titles or headers. Start directly with the visualization guidance.
        """
    }
}

class VisualizationCache {
    static let shared = VisualizationCache()
    
    private let fileManager = FileManager.default
    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = paths[0].appendingPathComponent("Visualizations")
        
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
        
        return cacheDir
    }
    
    func cacheKey(movement: String, cues: String, voice: VoiceOption) -> String {
        let combined = "\(movement)_\(cues)_\(voice.rawValue)"
        let hash = combined.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        let safeHash = hash.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .prefix(50)
        return String(safeHash)
    }
    
    func saveAudio(_ data: Data, key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).mp3")
        try data.write(to: fileURL)
    }
    
    func saveScript(_ script: String, key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).txt")
        try script.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func loadAudio(key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).mp3")
        return try? Data(contentsOf: fileURL)
    }
    
    func loadScript(key: String) -> String? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).txt")
        return try? String(contentsOf: fileURL, encoding: .utf8)
    }
    
    func hasCachedAudio(key: String) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).mp3")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func audioFileURL(key: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(key).mp3")
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
    }
    
    func cacheSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for file in files {
            if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        return totalSize
    }
}
