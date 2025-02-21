//
//  Hanuman_Chalisa_KidsApp.swift
//  Hanuman Chalisa Kids
//
//  Created by Madhur Grover on 2/13/25.
//

import SwiftUI

@main
struct Hanuman_Chalisa_KidsApp: App {
    @StateObject private var viewModel = VersesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
