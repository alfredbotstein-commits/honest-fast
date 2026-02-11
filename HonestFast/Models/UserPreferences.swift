import Foundation
import SwiftData

@Model
final class UserPreferences {
    var defaultPlan: String
    var reminderTime: Date?
    var eatingReminderTime: Date?
    var notificationsEnabled: Bool
    var milestoneNotifications: Bool
    var theme: String // "dark", "light", "system"
    var isPro: Bool
    var hasCompletedOnboarding: Bool
    var hasSeenProScreen: Bool
    
    init(
        defaultPlan: String = "16:8",
        reminderTime: Date? = nil,
        eatingReminderTime: Date? = nil,
        notificationsEnabled: Bool = true,
        milestoneNotifications: Bool = true,
        theme: String = "dark",
        isPro: Bool = false,
        hasCompletedOnboarding: Bool = false,
        hasSeenProScreen: Bool = false
    ) {
        self.defaultPlan = defaultPlan
        self.reminderTime = reminderTime
        self.eatingReminderTime = eatingReminderTime
        self.notificationsEnabled = notificationsEnabled
        self.milestoneNotifications = milestoneNotifications
        self.theme = theme
        self.isPro = isPro
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasSeenProScreen = hasSeenProScreen
    }
}
