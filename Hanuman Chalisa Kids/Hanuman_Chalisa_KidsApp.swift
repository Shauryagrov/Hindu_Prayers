//
//  Hanuman_Chalisa_KidsApp.swift
//  Hanuman Chalisa Kids
//
//  Created by Madhur Grover on 2/13/25.
//

import SwiftUI
import AVFoundation

@main
struct Hanuman_Chalisa_KidsApp: App {
    @StateObject private var viewModel = VersesViewModel()
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        setupAppearance()
        
        // Configure AVAudioSession at app launch
        // Using .playback category ensures audio plays even when device is in silent mode
        // Using .spokenAudio mode optimizes for speech synthesis
        // Using .defaultToSpeaker ensures audio plays through speaker even if headphones aren't connected
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.defaultToSpeaker, .duckOthers]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("Initial audio session configured successfully - will play in silent mode")
        } catch {
            print("Failed to configure initial audio session: \(error)")
            // Try fallback configuration
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .spokenAudio)
                try session.setActive(true)
                print("Fallback audio session configured")
            } catch {
                print("Failed to configure fallback audio session: \(error)")
            }
        }
        
        // Register for audio session interruptions
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main) { notification in
                guard let info = notification.userInfo,
                      let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
                }
                
                if type == .began {
                    print("Audio session interrupted")
                } else if type == .ended {
                    print("Audio session interruption ended")
                    // Try to reactivate the session
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print("Failed to reactivate audio session: \(error)")
                    }
                }
            }
    }
    
    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.orange.opacity(0.1))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.orange]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(appState)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        appState.appDidBecomeActive()
                    case .inactive:
                        appState.appWillResignActive()
                    case .background:
                        appState.appDidEnterBackground()
                    @unknown default:
                        break
                    }
                }
        }
    }
}

class AppState: ObservableObject {
    func appDidBecomeActive() {
        // Resume any paused tasks
        print("App became active")
    }
    
    func appWillResignActive() {
        // Pause ongoing tasks
        print("App will resign active")
    }
    
    func appDidEnterBackground() {
        // Save state, stop audio, etc.
        print("App entered background")
    }
}
