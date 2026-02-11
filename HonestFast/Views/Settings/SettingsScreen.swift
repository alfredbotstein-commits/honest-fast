import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Query private var preferences: [UserPreferences]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var fastingManager: FastingManager
    
    @State private var showClearConfirmation = false
    
    private var prefs: UserPreferences? { preferences.first }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                List {
                    // Fasting Plan
                    Section("Fasting Plan") {
                        HStack {
                            Text("Default Plan")
                            Spacer()
                            Text(prefs?.defaultPlan ?? "16:8")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    
                    // Appearance
                    Section("Appearance") {
                        Picker("Theme", selection: Binding(
                            get: { prefs?.theme ?? "dark" },
                            set: { newValue in
                                prefs?.theme = newValue
                                try? modelContext.save()
                            }
                        )) {
                            Text("Dark").tag("dark")
                            Text("Light").tag("light")
                            Text("System").tag("system")
                        }
                    }
                    
                    // Notifications
                    Section("Notifications") {
                        Toggle("Fast Complete", isOn: Binding(
                            get: { prefs?.notificationsEnabled ?? true },
                            set: { prefs?.notificationsEnabled = $0; try? modelContext.save() }
                        ))
                        
                        Toggle("Fasting Milestones", isOn: Binding(
                            get: { prefs?.milestoneNotifications ?? true },
                            set: { prefs?.milestoneNotifications = $0; try? modelContext.save() }
                        ))
                    }
                    
                    // Data
                    Section("Data") {
                        Button("Clear All Data") {
                            showClearConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                    
                    // About
                    Section("About") {
                        HStack {
                            Text("Honest Fast Pro")
                            Spacer()
                            Text(prefs?.isPro == true ? "✅ Unlocked" : "Unlock — $6.99")
                                .foregroundColor(prefs?.isPro == true ? Theme.success : Theme.accent)
                        }
                        
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Clear All Data?", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will delete all your fasting history. This cannot be undone.")
            }
        }
    }
    
    private func clearAllData() {
        HapticService.deleteAction()
        try? modelContext.delete(model: FastRecord.self)
        try? modelContext.save()
    }
}
