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
                    // Note: PrayerLibraryView has its own NavigationStack
                    PrayerLibraryView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Library", systemImage: "books.vertical.fill")
                        }
                        .tag(0)
                    
                    // Second tab - Bookmarks (Quick access to saved prayers)
                    // Note: BookmarksView has its own NavigationStack
                    BookmarksView()
                        .environmentObject(viewModel)
                        .tabItem {
                            Label("Bookmarks", systemImage: "bookmark.fill")
                        }
                        .tag(1)
                    
                    // Third tab - Settings
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
                    .tag(2)
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
