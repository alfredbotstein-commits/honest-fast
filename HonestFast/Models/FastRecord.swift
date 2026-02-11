import Foundation
import SwiftData

@Model
final class FastRecord {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var targetHours: Double
    var planName: String
    var completed: Bool
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        targetHours: Double,
        planName: String,
        completed: Bool = false
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.targetHours = targetHours
        self.planName = planName
        self.completed = completed
    }
    
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    var durationHours: Double {
        duration / 3600.0
    }
    
    var isActive: Bool {
        endDate == nil
    }
    
    var targetDuration: TimeInterval {
        targetHours * 3600.0
    }
    
    var progress: Double {
        guard targetDuration > 0 else { return 0 }
        return min(duration / targetDuration, 1.0)
    }
    
    var timeRemaining: TimeInterval {
        max(targetDuration - duration, 0)
    }
    
    var hitTarget: Bool {
        durationHours >= targetHours
    }
}
