import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    
    private var prefs: UserPreferences? { preferences.first }
    
    var body: some View {
        Group {
            if prefs?.hasCompletedOnboarding == true {
                mainTabView
            } else {
                OnboardingView(onComplete: {
                    if let p = prefs {
                        p.hasCompletedOnboarding = true
                    } else {
                        let p = UserPreferences(hasCompletedOnboarding: true)
                        modelContext.insert(p)
                    }
                    try? modelContext.save()
                })
            }
        }
        .onAppear {
            fastingManager.configure(modelContext: modelContext)
            if preferences.isEmpty {
                let p = UserPreferences()
                modelContext.insert(p)
                try? modelContext.save()
            }
            NotificationService.shared.requestPermission()
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TimerScreen()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                .tag(0)
            
            HistoryScreen()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
            
            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(Theme.accent)
    }
}
