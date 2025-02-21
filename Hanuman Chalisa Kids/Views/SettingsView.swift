import SwiftUI

struct SettingsView: View {
    let showWelcome: () -> Void
    @EnvironmentObject var viewModel: VersesViewModel
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Voice Settings")) {
                VStack(alignment: .leading) {
                    Text("Speech Rate")
                    HStack {
                        Image(systemName: "tortoise")
                        Slider(
                            value: $viewModel.speechRate,
                            in: 0.3...0.6,
                            step: 0.1
                        )
                        Image(systemName: "hare")
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
                Text("Hanuman Chalisa Kids App")
                    .font(.headline)
                Text("Version 1.0")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationView {
        SettingsView(showWelcome: {})
            .environmentObject(VersesViewModel())
    }
} 