import Foundation

/// Service for interacting with OpenAI API
class LLMService {
    static let shared = LLMService()
    
    private let apiKeyKey = "OpenAI_API_Key"
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    /// Get API key from UserDefaults
    var apiKey: String? {
        get {
            UserDefaults.standard.string(forKey: apiKeyKey)
        }
        set {
            if let key = newValue {
                UserDefaults.standard.set(key, forKey: apiKeyKey)
            } else {
                UserDefaults.standard.removeObject(forKey: apiKeyKey)
            }
        }
    }
    
    /// Check if API key is configured
    var isConfigured: Bool {
        apiKey != nil && !apiKey!.isEmpty
    }
    
    /// Generate answer using OpenAI API with RAG context
    func generateAnswer(
        question: String,
        context: String,
        prayerTitle: String
    ) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw LLMError.apiKeyNotSet
        }
        
        // Construct the prompt with context
        let systemPrompt = """
        You are a helpful assistant that answers questions about Hindu prayers and religious texts, especially for children.
        You have access to the following prayer content. Use this information to provide accurate, kid-friendly answers.
        If the question cannot be answered from the provided context, say so politely.
        Keep answers concise, clear, and appropriate for children learning about their faith.
        """
        
        let userPrompt = """
        Prayer: \(prayerTitle)
        
        Context:
        \(context)
        
        Question: \(question)
        
        Please provide a helpful answer based on the context above.
        """
        
        // Create the API request
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini", // Using mini for cost efficiency
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500 // Limit response length
        ]
        
        guard let url = URL(string: baseURL) else {
            throw LLMError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw LLMError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                throw LLMError.rateLimitExceeded
            } else {
                throw LLMError.apiError(statusCode: httpResponse.statusCode)
            }
        }
        
        // Parse the response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum LLMError: LocalizedError {
    case apiKeyNotSet
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case rateLimitExceeded
    case apiError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "OpenAI API key is not set. Please add your API key in Settings."
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .invalidAPIKey:
            return "Invalid API key. Please check your API key in Settings."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .apiError(let statusCode):
            return "API error (status code: \(statusCode))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

