import Foundation

extension String {
    func containsDevanagari() -> Bool {
        let devanagariRange = "\u{0900}"..."\u{097F}"  // Devanagari Unicode range
        return self.contains { char in
            guard let scalar = String(char).unicodeScalars.first else { return false }
            return devanagariRange.contains(String(scalar))
        }
    }

    // Cache for highlighted text to avoid redundant processing
    private static var highlightCache = NSCache<NSString, NSAttributedString>()
    
    func highlightWord(_ word: String?, range: NSRange?, cacheKey: String? = nil) -> AttributedString {
        // Check cache first if we have a cache key
        if let cacheKey = cacheKey, 
           let cached = String.highlightCache.object(forKey: cacheKey as NSString) {
            return AttributedString(cached)
        }
        
        var attributed = AttributedString(self)
        
        guard word != nil, let range = range else {
            return attributed
        }
        
        let nsString = self as NSString
        if range.location + range.length <= nsString.length {
            let wordInRange = nsString.substring(with: range)
            if let textRange = self.range(of: wordInRange) {
                let attributedRange = Range(textRange, in: attributed)!
                attributed[attributedRange].foregroundColor = .blue
                attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
            }
        }
        
        // Cache the result if we have a cache key
        if let cacheKey = cacheKey {
            let nsAttributed = NSAttributedString(attributed)
            String.highlightCache.setObject(nsAttributed, forKey: cacheKey as NSString)
        }
        
        return attributed
    }
} 