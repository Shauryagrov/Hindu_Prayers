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
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView(showMainApp: { tab in
                    print("ContentView: Transitioning to tab \(tab)")
                    selectedTab = tab
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                    }
                })
            } else {
                MainTabView(
                    selectedTab: selectedTab,
                    showWelcome: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showWelcome = true
                        }
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showWelcome)
        .onChange(of: showWelcome) { _, newValue in
            print("ContentView: showWelcome changed to \(newValue)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(VersesViewModel())
}
