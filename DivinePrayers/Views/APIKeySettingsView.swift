import SwiftUI

struct APIKeySettingsView: View {
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("OpenAI API Key")) {
                SecureField("sk-...", text: $apiKey)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Text("This feature is no longer required.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("How to get an API Key")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Visit platform.openai.com")
                    Text("2. Sign up or log in")
                    Text("3. Go to API Keys section")
                    Text("4. Create a new secret key")
                    Text("5. Copy and paste it here")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Link("Open OpenAI Website", destination: URL(string: "https://platform.openai.com/api-keys")!)
                    .font(.subheadline)
            }
            
            Section {
                Button(action: saveAPIKey) {
                    HStack {
                        Spacer()
                        Text("Save API Key")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(AppGradients.saffronGold)
                    .cornerRadius(10)
                }
                
                if LLMService.shared.isConfigured {
                    Button(role: .destructive, action: removeAPIKey) {
                        HStack {
                            Spacer()
                            Text("Remove API Key")
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("API Key Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load existing key (show masked version)
            if let existingKey = LLMService.shared.apiKey, !existingKey.isEmpty {
                // Show last 4 characters
                let masked = String(repeating: "•", count: max(0, existingKey.count - 4)) + existingKey.suffix(4)
                apiKey = masked
            }
        }
        .alert("API Key", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedKey.isEmpty {
            alertMessage = "Please enter an API key"
            showAlert = true
            return
        }
        
        // If it's the masked version, don't update
        if trimmedKey.hasPrefix("•") {
            alertMessage = "Please enter a new API key"
            showAlert = true
            return
        }
        
        if !trimmedKey.hasPrefix("sk-") {
            alertMessage = "OpenAI API keys should start with 'sk-'"
            showAlert = true
            return
        }
        
        LLMService.shared.apiKey = trimmedKey
        alertMessage = "API key saved successfully!"
        showAlert = true
        
        // Clear the field after saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            apiKey = ""
            dismiss()
        }
    }
    
    private func removeAPIKey() {
        LLMService.shared.apiKey = nil
        apiKey = ""
        alertMessage = "API key removed"
        showAlert = true
    }
}

#Preview {
    NavigationStack {
        APIKeySettingsView()
    }
}

