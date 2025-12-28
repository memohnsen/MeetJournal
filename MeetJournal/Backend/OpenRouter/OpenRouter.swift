//
//  OpenRouter.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/27/25.
//

import Foundation

@Observable
class OpenRouter {
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENROUTER_API_KEY") as! String
    private let url = "https://openrouter.ai/api/v1/chat/completions"
    // google/gemini-2.5-flash       | $0.30 in | $2.5 out | poor analysis, not good at spotting trends, convulted
    // google/gemini-3-flash-preview | $0.50 in | $3 out   | ues big words, but very good analysis, found trends successfully
    // anthropic/claude-sonnet-4.5   | $3 in    | $15 out  | slowest, verbose, less big words
    // xiaomi/mimo-v2-flash:free     | free     | free     | correlated scores to overall, bad analysis
    // minimax/minimax-m2            | $0.20 in | $1 out   | cheap, poor at instructions
    private let model = "google/gemini-3-flash-preview"
    
    var response: String = ""
    var isLoading: Bool = false
    
    func query(prompt: String) async throws -> String {
        isLoading = true
        guard let requestURL = URL(string: url) else {
            throw NSError(domain: "OpenRouterError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "OpenRouterError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "OpenRouterError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        self.response = content
        isLoading = false
        return self.response
    }
}
