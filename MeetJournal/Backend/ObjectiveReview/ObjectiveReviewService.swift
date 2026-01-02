import Foundation
import Clerk

@Observable
class ObjectiveReviewService {
    private let openRouter = OpenRouter()
    
    var isReframing: Bool = false
    var error: String?
    
    func reframeAthleteVent(ventText: String, sport: String) async throws -> String {
        isReframing = true
        error = nil
        defer { isReframing = false }
        
        let prompt = buildReframingPrompt(ventText: ventText, sport: sport)
        
        do {
            let reframedText = try await openRouter.query(prompt: prompt, purpose: "objective_review")
            return reframedText
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    private func buildReframingPrompt(ventText: String, sport: String) -> String {
        """
        You are a professional \(sport) coach. An athlete just shared their emotional reaction to a set. Your job is to transform their emotional, subjective feedback into objective, actionable coaching cues.
        
        Athlete's emotional feedback:
        "\(ventText)"
        
        Transform this into objective coaching perspective. Focus on:
        1. Identifying the specific technical issue (bar path, positioning, timing, etc.)
        2. Providing concrete, actionable cues for the next attempt
        3. Using technical language appropriate for \(sport)
        4. Being direct and helpful, not overly positive or negative
        
        Format your response as a brief coaching note that the athlete can use as a training cue. Keep it concise (2-3 sentences max). Focus on what to do differently, not what went wrong.
        
        Example transformation:
        Athlete: "I'm a disaster. I let the bar drift forward and I just gave up because I felt weak."
        Coach: "The bar path drifted forward at the sticking point. Focus on 'chest up' and 'driving through the mid-foot' on the next attempt."
        
        Response Format:
            - No emojis
            - Do not include any greetings, get straight to the data
            - Write as plain text, no markdown
        """
    }
}

