// Create a dedicated error handling system
import Foundation

enum AppError: Error, Identifiable {
    case audioPlayback(description: String, underlyingError: Error? = nil)
    case dataLoading(description: String, underlyingError: Error? = nil)
    case networkError(description: String, underlyingError: Error? = nil)
    
    var id: String {
        switch self {
        case .audioPlayback: return "audio_playback"
        case .dataLoading: return "data_loading"
        case .networkError: return "network_error"
        }
    }
    
    var userMessage: String {
        switch self {
        case .audioPlayback(let description, _):
            return "Audio playback issue: \(description)"
        case .dataLoading(let description, _):
            return "Data loading issue: \(description)"
        case .networkError(let description, _):
            return "Network issue: \(description)"
        }
    }
    
    var logMessage: String {
        // Detailed message for logging
        switch self {
        case .audioPlayback(let description, let error):
            return "Audio playback error: \(description), underlying error: \(error?.localizedDescription ?? "none")"
        case .dataLoading(let description, let error):
            return "Data loading error: \(description), underlying error: \(error?.localizedDescription ?? "none")"
        case .networkError(let description, let error):
            return "Network error: \(description), underlying error: \(error?.localizedDescription ?? "none")"
        }
    }
}

// Error handling service
import SwiftUI

class ErrorHandlingService: ObservableObject {
    @Published var currentError: AppError?
    @Published var showingError = false
    
    func handle(_ error: AppError) {
        // Log the error
        print(error.logMessage)
        
        // Update UI
        currentError = error
        showingError = true
        
        // Analytics tracking
        // AnalyticsService.shared.trackError(error)
    }
} 