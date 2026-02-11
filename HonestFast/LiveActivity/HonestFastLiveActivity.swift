import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes

struct FastingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var targetHours: Double
        var planName: String
        var stageName: String
    }
    
    var fastId: String
}

// MARK: - Live Activity Widget

struct FastingLiveActivity: Widget {
    let kind = "FastingLiveActivity"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FastingActivityAttributes.self) { context in
            // Lock Screen Banner
            lockScreenBanner(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    miniRing(context: context)
                        .frame(width: 44, height: 44)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.planName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(timerText(context: context))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.stageName)
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Spacer()
                        Text("ends \(endTimeText(context: context))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: "circle.dotted")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text(timerText(context: context))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundStyle(.orange)
            } minimal: {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(.orange)
            }
        }
    }
    
    @ViewBuilder
    private func lockScreenBanner(context: ActivityViewContext<FastingActivityAttributes>) -> some View {
        HStack(spacing: 12) {
            miniRing(context: context)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Honest Fast")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(timerText(context: context))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(context.state.planName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(context.state.stageName)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .activityBackgroundTint(.black.opacity(0.7))
    }
    
    @ViewBuilder
    private func miniRing(context: ActivityViewContext<FastingActivityAttributes>) -> some View {
        let progress = progressValue(context: context)
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(hoursText(context: context))
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
    }
    
    private func progressValue(context: ActivityViewContext<FastingActivityAttributes>) -> Double {
        let elapsed = Date().timeIntervalSince(context.state.startTime)
        let target = context.state.targetHours * 3600
        guard target > 0 else { return 0 }
        return min(elapsed / target, 1.0)
    }
    
    private func timerText(context: ActivityViewContext<FastingActivityAttributes>) -> String {
        let elapsed = max(0, Date().timeIntervalSince(context.state.startTime))
        let h = Int(elapsed) / 3600
        let m = (Int(elapsed) % 3600) / 60
        return String(format: "%d:%02d", h, m)
    }
    
    private func hoursText(context: ActivityViewContext<FastingActivityAttributes>) -> String {
        let elapsed = max(0, Date().timeIntervalSince(context.state.startTime))
        return "\(Int(elapsed / 3600))h"
    }
    
    private func endTimeText(context: ActivityViewContext<FastingActivityAttributes>) -> String {
        let end = context.state.startTime.addingTimeInterval(context.state.targetHours * 3600)
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: end)
    }
}
