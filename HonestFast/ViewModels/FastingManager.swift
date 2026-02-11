import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class FastingManager: ObservableObject {
    @Published var currentFast: FastRecord?
    @Published var selectedPlan: FastingPlan = FastingPlan.plans[0]
    @Published var customFastHours: Double = 16
    @Published var customEatHours: Double = 8
    @Published var timeRemaining: TimeInterval = 0
    @Published var elapsed: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var currentStage: FastingStage = .risingBloodSugar
    @Published var isComplete: Bool = false
    
    private var timer: Timer?
    private var modelContext: ModelContext?
    
    var fastHours: Double {
        selectedPlan.id == "Custom" ? customFastHours : selectedPlan.fastHours
    }
    
    var isFasting: Bool {
        currentFast != nil && !isComplete
    }
    
    var startTime: Date? {
        currentFast?.startDate
    }
    
    var endTime: Date? {
        guard let start = currentFast?.startDate else { return nil }
        return start.addingTimeInterval(fastHours * 3600)
    }
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadActiveFast()
        setupWatchSync()
    }
    
    private func setupWatchSync() {
        WatchConnectivityService.shared.activate()
        WatchConnectivityService.shared.onStateReceived = { [weak self] dict in
            Task { @MainActor in
                self?.handleWatchStateUpdate(dict)
            }
        }
    }
    
    private func handleWatchStateUpdate(_ dict: [String: Any]) {
        guard let modelContext else { return }
        let watchFasting = dict["isFasting"] as? Bool ?? false
        let watchStartTime = dict["fastStartTime"] as? Double ?? 0
        let watchTargetHours = dict["fastDurationHours"] as? Double ?? 16
        let watchPlanName = dict["planName"] as? String ?? "16:8"
        
        if watchFasting && currentFast == nil {
            // Watch started a fast — create record
            let record = FastRecord(
                startDate: Date(timeIntervalSince1970: watchStartTime),
                targetHours: watchTargetHours,
                planName: watchPlanName
            )
            modelContext.insert(record)
            try? modelContext.save()
            currentFast = record
            isComplete = false
            startTimer()
        } else if !watchFasting && currentFast != nil {
            // Watch ended the fast
            endFast()
        }
    }
    
    private func syncToShared() {
        if let fast = currentFast {
            SharedDefaults.updateFastingState(
                isFasting: true,
                startTime: fast.startDate,
                targetHours: fast.targetHours,
                planName: fast.planName
            )
        } else {
            SharedDefaults.clearFastingState()
        }
        WatchConnectivityService.shared.sendStateToWatch()
    }
    
    private func loadActiveFast() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<FastRecord>(
            predicate: #Predicate { $0.endDate == nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        if let active = try? modelContext.fetch(descriptor).first {
            currentFast = active
            selectedPlan = FastingPlan.plan(for: active.planName) ?? FastingPlan.plans[0]
            syncToShared()
            startTimer()
        } else {
            SharedDefaults.clearFastingState()
        }
    }
    
    func startFast() {
        guard let modelContext else { return }
        let planName = selectedPlan.id == "Custom" ? "Custom (\(Int(customFastHours)):\(Int(customEatHours)))" : selectedPlan.id
        let record = FastRecord(
            startDate: Date(),
            targetHours: fastHours,
            planName: planName
        )
        modelContext.insert(record)
        try? modelContext.save()
        
        currentFast = record
        isComplete = false
        
        HapticService.startFast()
        scheduleNotifications(for: record)
        syncToShared()
        startTimer()
    }
    
    func endFast() {
        guard let fast = currentFast, let modelContext else { return }
        fast.endDate = Date()
        fast.completed = fast.hitTarget
        try? modelContext.save()
        
        HapticService.endFast()
        NotificationService.shared.cancelAllFastNotifications()
        stopTimer()
        
        currentFast = nil
        isComplete = false
        progress = 0
        timeRemaining = 0
        elapsed = 0
        syncToShared()
    }
    
    func completeFast() {
        guard let fast = currentFast, let modelContext else { return }
        fast.endDate = Date()
        fast.completed = true
        try? modelContext.save()
        
        HapticService.fastComplete()
        isComplete = true
        stopTimer()
        syncToShared()
    }
    
    private func startTimer() {
        stopTimer()
        updateTimerState()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimerState()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimerState() {
        guard let fast = currentFast else { return }
        
        elapsed = fast.duration
        let elapsedHours = elapsed / 3600.0
        timeRemaining = fast.timeRemaining
        progress = fast.progress
        currentStage = FastingStage.stage(for: elapsedHours)
        
        if timeRemaining <= 0 && !isComplete {
            completeFast()
        }
    }
    
    private func scheduleNotifications(for fast: FastRecord) {
        let start = fast.startDate
        
        // Fast complete
        let endDate = start.addingTimeInterval(fast.targetHours * 3600)
        NotificationService.shared.scheduleFastComplete(at: endDate, planName: fast.planName)
        
        // Milestones
        for hours in [4, 8, 12, 16, 20, 24] {
            let milestoneDate = start.addingTimeInterval(Double(hours) * 3600)
            if milestoneDate > Date() && Double(hours) <= fast.targetHours {
                NotificationService.shared.scheduleMilestone(hours: hours, at: milestoneDate)
            }
        }
    }
    
    // MARK: - Stats
    
    func currentStreak(fasts: [FastRecord]) -> Int {
        let calendar = Calendar.current
        let completedFasts = fasts.filter { $0.completed }
        
        guard !completedFasts.isEmpty else { return 0 }
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Check if fasting today (active fast counts)
        if currentFast != nil {
            streak = 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while true {
            let dayStart = checkDate
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let hasFast = completedFasts.contains { fast in
                guard let end = fast.endDate else { return false }
                return end >= dayStart && end < dayEnd
            }
            
            if hasFast {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    func fastsThisWeek(fasts: [FastRecord]) -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return fasts.filter { fast in
            fast.completed && (fast.endDate ?? Date()) >= startOfWeek
        }.count
    }
}
