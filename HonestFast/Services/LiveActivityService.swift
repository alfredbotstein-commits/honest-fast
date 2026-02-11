import ActivityKit
import Foundation

@MainActor
enum LiveActivityService {
    private static var currentActivity: Activity<FastingActivityAttributes>?
    
    static func startActivity(fastId: String, startTime: Date, targetHours: Double, planName: String, stageName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = FastingActivityAttributes(fastId: fastId)
        let state = FastingActivityAttributes.ContentState(
            startTime: startTime,
            targetHours: targetHours,
            planName: planName,
            stageName: stageName
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }
    
    static func updateActivity(startTime: Date, targetHours: Double, planName: String, stageName: String) {
        guard let activity = currentActivity else { return }
        let state = FastingActivityAttributes.ContentState(
            startTime: startTime,
            targetHours: targetHours,
            planName: planName,
            stageName: stageName
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }
    
    static func endActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
