import SwiftUI

struct SettingsView: View {
    let showWelcome: () -> Void
    @EnvironmentObject var viewModel: VersesViewModel
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = true
    @Environment(\.dismiss) private var dismiss
    @State private var showingVoiceSettings = false
    
    var body: some View {
        Form {
            Section(header: Text("Audio")) {
                // Voice Selection
                Button(action: {
                    showingVoiceSettings = true
                }) {
                    HStack {
                        Image(systemName: "person.wave.2")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Voice Selection")
                                .foregroundColor(.primary)
                            Text("Choose Hindi and English voices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Quick Speech Rate Adjustment
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                    Text("Speech Rate")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(String(format: "%.1fx", viewModel.speechRate * 2))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Image(systemName: "tortoise")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Slider(
                            value: $viewModel.speechRate,
                            in: 0.2...0.8,
                            step: 0.05
                        )
                        .tint(.orange)
                        Image(systemName: "hare")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            Section(header: Text("Learning")) {
                Toggle(isOn: Binding(
                    get: { viewModel.showTransliteration },
                    set: { newValue in
                        viewModel.showTransliteration = newValue
                        UserDefaults.standard.set(newValue, forKey: "showTransliteration")
                    }
                )) {
                    HStack {
                        Image(systemName: "textformat.abc")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Transliteration")
                                .foregroundColor(.primary)
                            Text("Display English pronunciation below Hindi text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section {
                Button(action: showWelcome) {
                    HStack {
                        Text("Back to Welcome Screen")
                        Spacer()
                        Image(systemName: "arrow.left.circle.fill")
                    }
                    .foregroundColor(.orange)
                }
            }
            
            Section(header: Text("About")) {
                Text("DivinePrayers App")
                    .font(.headline)
                Text("Version 1.0")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingVoiceSettings) {
            VoiceSettingsView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(showWelcome: {})
            .environmentObject(VersesViewModel())
    }
} 