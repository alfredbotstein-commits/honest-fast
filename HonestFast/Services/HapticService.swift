import UIKit

enum HapticService {
    static func startFast() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func endFast() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func fastComplete() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func milestoneReached() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func streakMilestone() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.notificationOccurred(.success)
        }
    }
    
    static func deleteAction() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
