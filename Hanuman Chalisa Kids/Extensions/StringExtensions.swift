import Foundation

extension String {
    func containsDevanagari() -> Bool {
        let devanagariRange = "\u{0900}"..."\u{097F}"  // Devanagari Unicode range
        return self.contains { char in
            guard let scalar = String(char).unicodeScalars.first else { return false }
            return devanagariRange.contains(String(scalar))
        }
    }
} 