import SwiftUI

// First, let's fix the environment key definition
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    var selectedTab: Int {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct MainTabView: View {
    let selectedTab: Int
    let showWelcome: () -> Void
    @AppStorage("currentTab") private var currentTab: Int = 0
    @EnvironmentObject var viewModel: VersesViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        TabView(selection: $currentTab) {
            VerseListView()
                .tabItem {
                    Label("Verses", systemImage: "book.fill")
                }
                .tag(0)
            
            PlayChalisaView()
                .tabItem {
                    Label(
                        viewModel.isPlayingCompleteVersion ? "Stop" : "Play Chalisa",
                        systemImage: viewModel.isPlayingCompleteVersion ? "stop.circle.fill" : "play.circle.fill"
                    )
                }
                .tag(1)
            
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "gamecontroller.fill")
                }
                .tag(2)
            
            SettingsView(showWelcome: showWelcome)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.orange)
        .onAppear {
            currentTab = selectedTab
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                viewModel.stopCompleteChalisaPlayback()
            }
        }
        .onChange(of: currentTab) { oldValue, newValue in
            if oldValue == 1 {
                Task {
                    try? await Task.sleep(for: .milliseconds(100))
                    await MainActor.run {
                        viewModel.stopCompleteChalisaPlayback()
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView(selectedTab: 0, showWelcome: {})
        .environmentObject(VersesViewModel())
} 