import Foundation
import SwiftUI

/// Tracks the currently selected prayer across the app for context-aware features
class CurrentPrayerContext: ObservableObject {
    static let shared = CurrentPrayerContext()
    
    @Published var currentPrayer: Prayer?
    
    private init() {}
    
    /// Creates a fresh context for previews or isolated testing.
    static func preview() -> CurrentPrayerContext {
        let context = CurrentPrayerContext()
        return context
    }
    
    func setCurrentPrayer(_ prayer: Prayer?) {
        currentPrayer = prayer
    }
    
    func clearCurrentPrayer() {
        currentPrayer = nil
    }
}

