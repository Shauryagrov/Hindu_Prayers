//
//  ContentView.swift
//  Hanuman Chalisa Kids
//
//  Created by Madhur Grover on 2/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showWelcome = true
    @State private var selectedTab = 0
    @EnvironmentObject var viewModel: VersesViewModel
    @StateObject private var prayerContext = CurrentPrayerContext.shared
    @State private var isTransitioning = false
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView(showMainApp: { tab in
                    // Prevent multiple transitions
                    guard !isTransitioning else { return }
                    isTransitioning = true
                    
                    selectedTab = tab
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                        showOnboarding = true
                    }
                    
                    // Reset the transition flag after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isTransitioning = false
                    }
                })
            } else if showOnboarding {
                OnboardingIntroView(
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            showOnboarding = false
                        }
                    }
                )
            } else {
                // Embed the tab view directly in ContentView
                TabView(selection: $selectedTab) {
                    // Library tab
                    PrayerLibraryView()
                        .environmentObject(viewModel)
                        .environmentObject(prayerContext)
                        .tabItem {
                            Label("Library", systemImage: "books.vertical.fill")
                        }
                        .tag(0)
                    
                    // Quiz tab
                    QuizHomeView()
                        .environmentObject(viewModel)
                        .environmentObject(prayerContext)
                        .tabItem {
                            Label("Quiz", systemImage: "brain.head.profile")
                        }
                        .tag(1)
                    
                    // Blessings tab
                    BlessingsView()
                        .environmentObject(viewModel)
                        .environmentObject(prayerContext)
                        .tabItem {
                            Label("Blessings", systemImage: "sparkles")
                        }
                        .tag(2)
                    
                    // Settings tab
                    NavigationStack {
                        SettingsView(showWelcome: {
                            // Prevent multiple transitions
                            guard !isTransitioning else { return }
                            isTransitioning = true
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showWelcome = true
                            }
                            
                            // Reset the transition flag after animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                isTransitioning = false
                            }
                        })
                    }
                    .environmentObject(prayerContext)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
                }
                .onChange(of: selectedTab) { oldValue, newValue in
                    print("Tab changed from \(oldValue) to \(newValue)")
                    
                    // Always stop all audio when switching tabs
                    viewModel.stopAllAudio()
                    
                    // Store the selected tab
                    UserDefaults.standard.set(newValue, forKey: "selectedTab")
                    
                    // Check if we need to force switch to Library tab
                    if UserDefaults.standard.bool(forKey: "switchToLibraryTab") {
                        UserDefaults.standard.removeObject(forKey: "switchToLibraryTab")
                        if newValue != 0 {
                            selectedTab = 0
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToLibraryTab"))) { _ in
                    // Switch to Library tab when notification is received
                    withAnimation {
                        selectedTab = 0
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToSettingsTab"))) { _ in
                    // Switch to Settings tab when notification is received
                    withAnimation {
                        selectedTab = 3
                    }
                }
                .onAppear {
                    // Check if we need to switch to Library tab (set from UserDefaults)
                    if UserDefaults.standard.bool(forKey: "switchToLibraryTab") {
                        UserDefaults.standard.removeObject(forKey: "switchToLibraryTab")
                        selectedTab = 0
                    }
                    // Check if we need to switch to Settings tab
                    if UserDefaults.standard.bool(forKey: "switchToSettingsTab") {
                        UserDefaults.standard.removeObject(forKey: "switchToSettingsTab")
                        selectedTab = 2
                    }
                    if selectedTab > 3 {
                        selectedTab = 0
                    }
                }
                .onChange(of: selectedTab) { oldValue, newValue in
                    // Clear switchToSettingsTab flag when tab changes
                    if UserDefaults.standard.bool(forKey: "switchToSettingsTab") {
                        UserDefaults.standard.removeObject(forKey: "switchToSettingsTab")
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showWelcome)
    }
}

#Preview {
    ContentViewPreviewContainer()
}

private struct ContentViewPreviewContainer: View {
    @StateObject private var store = BlessingProgressStore(defaults: UserDefaults())
    
    var body: some View {
        ContentView()
            .environmentObject(VersesViewModel())
            .environmentObject(CurrentPrayerContext.preview())
            .environmentObject(store)
    }
}
