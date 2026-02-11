import Foundation
import WidgetKit

/// Shared UserDefaults for App Group communication between app, widget, and watch
enum SharedDefaults {
    static let suiteName = "group.com.loopspur.honestfast"
    
    static var shared: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let isFasting = "isFasting"
        static let fastStartTime = "fastStartTime"
        static let fastDurationHours = "fastDurationHours"
        static let planName = "planName"
        static let lastSyncTimestamp = "lastSyncTimestamp"
    }
    
    // MARK: - Read
    
    static var isFasting: Bool {
        shared.bool(forKey: Keys.isFasting)
    }
    
    static var fastStartTime: TimeInterval {
        shared.double(forKey: Keys.fastStartTime)
    }
    
    static var fastDurationHours: Double {
        shared.double(forKey: Keys.fastDurationHours)
    }
    
    static var planName: String {
        shared.string(forKey: Keys.planName) ?? "16:8"
    }
    
    static var lastSyncTimestamp: TimeInterval {
        shared.double(forKey: Keys.lastSyncTimestamp)
    }
    
    // MARK: - Write
    
    static func updateFastingState(
        isFasting: Bool,
        startTime: Date? = nil,
        targetHours: Double = 16,
        planName: String = "16:8"
    ) {
        let defaults = shared
        defaults.set(isFasting, forKey: Keys.isFasting)
        defaults.set(startTime?.timeIntervalSince1970 ?? 0, forKey: Keys.fastStartTime)
        defaults.set(targetHours, forKey: Keys.fastDurationHours)
        defaults.set(planName, forKey: Keys.planName)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastSyncTimestamp)
        
        // Tell widgets to refresh
        WidgetKit.WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func clearFastingState() {
        updateFastingState(isFasting: false)
    }
    
    // MARK: - Dictionary representation (for WatchConnectivity)
    
    static func currentStateDict() -> [String: Any] {
        return [
            Keys.isFasting: isFasting,
            Keys.fastStartTime: fastStartTime,
            Keys.fastDurationHours: fastDurationHours,
            Keys.planName: planName,
            Keys.lastSyncTimestamp: Date().timeIntervalSince1970
        ]
    }
    
    static func apply(dict: [String: Any]) {
        let defaults = shared
        if let v = dict[Keys.isFasting] as? Bool { defaults.set(v, forKey: Keys.isFasting) }
        if let v = dict[Keys.fastStartTime] as? Double { defaults.set(v, forKey: Keys.fastStartTime) }
        if let v = dict[Keys.fastDurationHours] as? Double { defaults.set(v, forKey: Keys.fastDurationHours) }
        if let v = dict[Keys.planName] as? String { defaults.set(v, forKey: Keys.planName) }
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastSyncTimestamp)
        
        WidgetKit.WidgetCenter.shared.reloadAllTimelines()
    }
}
