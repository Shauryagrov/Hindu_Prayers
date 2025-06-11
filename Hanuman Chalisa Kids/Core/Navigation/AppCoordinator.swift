// Implement a coordinator pattern
import SwiftUI

class AppCoordinator: ObservableObject {
    enum Destination: Hashable {
        case verseList
        case verseDetail(Verse)
        case completeChalisaView
        case quiz
        case settings
    }
    
    @Published var path = NavigationPath()
    @Published var tabSelection: Int = 0
    
    func navigateTo(_ destination: Destination) {
        switch destination {
        case .verseList:
            // Clear path and go to verses tab
            path = NavigationPath()
            tabSelection = 0
        case .verseDetail(let verse):
            // Navigate to verse detail
            path.append(verse)
        case .completeChalisaView:
            // Go to complete chalisa tab
            tabSelection = 1
        case .quiz:
            // Go to quiz tab
            tabSelection = 2
        case .settings:
            // Go to settings tab
            tabSelection = 3
        }
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
} 