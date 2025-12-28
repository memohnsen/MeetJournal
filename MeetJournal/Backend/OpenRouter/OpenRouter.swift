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
    private let model = "google/gemini-2.5-flash"
    
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
        return self.response
        
        isLoading = false
    }
}
