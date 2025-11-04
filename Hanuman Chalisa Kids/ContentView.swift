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
    @State private var isTransitioning = false
    
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
                    }
                    
                    // Reset the transition flag after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isTransitioning = false
                    }
                })
            } else {
                // Embed the tab view directly in ContentView
                TabView(selection: $selectedTab) {
                    // First tab - Library (Main entry point - shows all prayers)
                    NavigationStack {
                        PrayerLibraryView()
                    }
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                    .tag(0)
                    
                    // Second tab - Verses (Hanuman Chalisa verses)
                    NavigationStack {
                        // Try VerseListView instead of VersesListView
                        VerseListView()
                    }
                    .tabItem {
                        Label("Verses", systemImage: "book.fill")
                    }
                    .tag(1)
                    
                    // Third tab - Quiz (Hanuman Chalisa quiz)
                    NavigationStack {
                        QuizView()
                    }
                    .tabItem {
                        Label("Quiz", systemImage: "questionmark.circle.fill")
                    }
                    .tag(2)
                    
                    // Fourth tab - Complete (Complete Hanuman Chalisa playback)
                    NavigationStack {
                        CompleteChalisaView()
                    }
                    .tabItem {
                        Label("Complete", systemImage: "text.book.closed.fill")
                    }
                    .tag(3)
                    
                    // Fifth tab - Settings
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
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
                }
                .onChange(of: selectedTab) { oldValue, newValue in
                    print("Tab changed from \(oldValue) to \(newValue)")
                    
                    // Always stop all audio when switching tabs
                    viewModel.stopAllAudio()
                    
                    // Store the selected tab
                    UserDefaults.standard.set(newValue, forKey: "selectedTab")
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showWelcome)
    }
}

#Preview {
    ContentView()
        .environmentObject(VersesViewModel())
}
