import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleFastComplete(at date: Date, planName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Fast Complete! 🎉"
        content.body = "Your \(planName) fast is complete!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "fast-complete",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleMilestone(hours: Int, at date: Date) {
        let messages: [Int: (String, String)] = [
            4: ("4 Hours In", "Your blood sugar is settling down."),
            8: ("8 Hours In", "Blood sugar at baseline. Burning through glycogen."),
            12: ("12 Hours 🔥", "Fat burning is kicking in."),
            16: ("16 Hours ✨", "Heavy ketosis. You're in the zone."),
            20: ("20 Hours 💪", "Deep ketosis. Your body is fully fat-adapted."),
            24: ("24 Hours 🧬", "Autophagy territory. Cellular cleanup in progress."),
        ]
        
        guard let (title, body) = messages[hours] else { return }
        guard date.timeIntervalSinceNow > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: date.timeIntervalSinceNow,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "milestone-\(hours)h",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllFastNotifications() {
        let ids = ["fast-complete", "milestone-4h", "milestone-8h", "milestone-12h", "milestone-16h", "milestone-20h", "milestone-24h"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
