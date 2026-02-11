import SwiftUI
import SwiftData

@main
struct HonestFastApp: App {
    @StateObject private var fastingManager = FastingManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fastingManager)
                .modelContainer(for: [FastRecord.self, UserPreferences.self])
                .preferredColorScheme(.dark)
        }
    }
}
