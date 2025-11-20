import SwiftUI
import AVFoundation

struct VoiceSettingsView: View {
    @EnvironmentObject var viewModel: VersesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var availableHindiVoices: [VoiceInfo] = []
    @State private var availableEnglishVoices: [VoiceInfo] = []
    @State private var selectedHindiVoice: String = UserDefaults.standard.string(forKey: "selectedHindiVoice") ?? "default"
    @State private var selectedEnglishVoice: String = UserDefaults.standard.string(forKey: "selectedEnglishVoice") ?? "default"
    @State private var speechRate: Float = UserDefaults.standard.float(forKey: "speechRate") != 0 ? UserDefaults.standard.float(forKey: "speechRate") : 0.4
    @State private var previewSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationView {
            List {
                // Info Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Choose Your Voices")
                                .font(.headline)
                            Text("Select one voice for Hindi and one for English. Your choices will be used throughout the app.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Speech Rate Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Speech Rate")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.1fx", speechRate * 2))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $speechRate, in: 0.2...0.8, step: 0.05)
                            .tint(.orange)
                            .onChange(of: speechRate) { _, newValue in
                                UserDefaults.standard.set(newValue, forKey: "speechRate")
                                viewModel.speechRate = newValue
                            }
                        
                        HStack {
                            Text("Slow")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Fast")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Playback Speed")
                }
                
                // Hindi Voice Section
                Section {
                    ForEach(availableHindiVoices, id: \.identifier) { voice in
                        VoiceRow(
                            voice: voice,
                            isSelected: selectedHindiVoice == voice.identifier,
                            onSelect: {
                                selectedHindiVoice = voice.identifier
                                UserDefaults.standard.set(voice.identifier, forKey: "selectedHindiVoice")
                                viewModel.clearVoiceCache()
                                // Stop any current playback so new voice will be used on next play
                                viewModel.stopAllAudio()
                            },
                            onPreview: {
                                previewVoice(voice, text: "नमस्ते, यह हनुमान चालीसा ऐप है")
                            }
                        )
                    }
                } header: {
                    Text("Hindi Voice")
                } footer: {
                    Text("This voice will be used for all Hindi verse text. Tap the play button to hear a sample.")
                }
                
                // English Voice Section
                Section {
                    ForEach(availableEnglishVoices, id: \.identifier) { voice in
                        VoiceRow(
                            voice: voice,
                            isSelected: selectedEnglishVoice == voice.identifier,
                            onSelect: {
                                selectedEnglishVoice = voice.identifier
                                UserDefaults.standard.set(voice.identifier, forKey: "selectedEnglishVoice")
                                viewModel.clearVoiceCache()
                                // Stop any current playback so new voice will be used on next play
                                viewModel.stopAllAudio()
                            },
                            onPreview: {
                                previewVoice(voice, text: "Hello, this is the Hanuman Chalisa app")
                            }
                        )
                    }
                } header: {
                    Text("English Voice")
                } footer: {
                    Text("This voice will be used for all English translations and explanations throughout the app.")
                }
                
                // Download More Voices Section
                Section {
                    Link(destination: URL(string: "App-prefs:root=ACCESSIBILITY&path=SPOKEN_CONTENT")!) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.orange)
                            Text("Download More Voices")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } footer: {
                    Text("Go to Settings → Accessibility → Spoken Content → Voices to download high-quality premium voices like Lekha (Hindi) or Veena, Rishi (Indian English).")
                }
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
            .onAppear {
                loadAvailableVoices()
            }
            .onDisappear {
                // Stop any playing preview when leaving
                if previewSynthesizer.isSpeaking {
                    previewSynthesizer.stopSpeaking(at: .immediate)
                }
            }
        }
    }
    
    private func loadAvailableVoices() {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Filter Hindi voices
        availableHindiVoices = allVoices
            .filter { voice in
                voice.language.hasPrefix("hi")
            }
            .map { voice in
                VoiceInfo(
                    identifier: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    quality: getQualityString(voice.quality)
                )
            }
        
        // Add default option if no voices found
        if availableHindiVoices.isEmpty {
            availableHindiVoices.append(VoiceInfo(
                identifier: "default",
                name: "System Default",
                language: "hi-IN",
                quality: "Default"
            ))
        }
        
        // Filter English voices (prefer Indian English)
        let englishVoices = allVoices
            .filter { voice in
                voice.language.hasPrefix("en")
            }
            .sorted { voice1, voice2 in
                // Prioritize Indian English
                if voice1.language.contains("IN") && !voice2.language.contains("IN") {
                    return true
                } else if !voice1.language.contains("IN") && voice2.language.contains("IN") {
                    return false
                }
                // Then by quality
                return voice1.quality.rawValue > voice2.quality.rawValue
            }
            .map { voice in
                VoiceInfo(
                    identifier: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    quality: getQualityString(voice.quality)
                )
            }
        
        availableEnglishVoices = englishVoices
        
        // Add default option if no voices found
        if availableEnglishVoices.isEmpty {
            availableEnglishVoices.append(VoiceInfo(
                identifier: "default",
                name: "System Default",
                language: "en-US",
                quality: "Default"
            ))
        }
    }
    
    private func getQualityString(_ quality: AVSpeechSynthesisVoiceQuality) -> String {
        switch quality {
        case .default:
            return "Default"
        case .enhanced:
            return "Enhanced"
        case .premium:
            return "Premium"
        @unknown default:
            return "Default"
        }
    }
    
    private func previewVoice(_ voice: VoiceInfo, text: String) {
        // Stop any currently playing preview
        if previewSynthesizer.isSpeaking {
            previewSynthesizer.stopSpeaking(at: .immediate)
        }
        
        // Setup audio session for preview
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session for preview: \(error)")
        }
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        
        // Set the voice
        if voice.identifier == "default" {
            utterance.voice = AVSpeechSynthesisVoice(language: voice.language)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice.identifier)
        }
        
        // Set speech rate
        utterance.rate = speechRate
        
        // Speak using the dedicated preview synthesizer
        previewSynthesizer.speak(utterance)
    }
}

// MARK: - Voice Info Model
struct VoiceInfo {
    let identifier: String
    let name: String
    let language: String
    let quality: String
}

// MARK: - Voice Row Component
private struct VoiceRow: View {
    let voice: VoiceInfo
    let isSelected: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack(spacing: 12) {
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .orange : .gray.opacity(0.3))
                        .font(.title3)
                    
                    // Voice info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(voice.name)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text(voice.language)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if voice.quality != "Default" {
                                Text(voice.quality)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Preview button
            Button(action: onPreview) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VoiceSettingsView()
        .environmentObject(VersesViewModel())
}

