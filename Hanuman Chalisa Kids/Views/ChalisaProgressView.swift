import SwiftUI

struct ChalisaProgressView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Current section indicator
            Text(currentSectionTitle)
                .font(.headline)
                .foregroundColor(.orange)
            
            // Progress indicator
            HStack(spacing: 16) {
                // Opening Dohas progress
                Circle()
                    .fill(sectionColor(for: .openingDoha))
                    .frame(width: 12, height: 12)
                
                // Main verses progress
                Rectangle()
                    .fill(sectionColor(for: .chaupai))
                    .frame(height: 4)
                
                // Closing Doha progress
                Circle()
                    .fill(sectionColor(for: .closingDoha))
                    .frame(width: 12, height: 12)
            }
            .padding(.horizontal)
            
            // Current item being played
            Text(currentItemText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var currentSectionTitle: String {
        switch viewModel.currentSection {
        case .openingDoha:
            return "Opening Dohas"
        case .chaupai:
            return "Main Verses"
        case .closingDoha:
            return "Closing Doha"
        }
    }
    
    private var currentItemText: String {
        switch viewModel.currentSection {
        case .openingDoha:
            return "Doha \(viewModel.currentDohaIndex + 1) of 2"
        case .chaupai:
            return "Verse \(viewModel.currentChalisaVerseIndex + 1) of 40"
        case .closingDoha:
            return "Final Doha"
        }
    }
    
    private func sectionColor(for section: VersesViewModel.ChalisaSection) -> Color {
        if viewModel.currentSection == section {
            return .orange
        } else if viewModel.isPlayingCompleteVersion {
            return .orange.opacity(0.3)
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    ChalisaProgressView()
        .environmentObject(VersesViewModel())
} 