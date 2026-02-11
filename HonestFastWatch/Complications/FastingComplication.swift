import WidgetKit
import SwiftUI

struct WatchFastingEntry: TimelineEntry {
    let date: Date
    let isFasting: Bool
    let startTime: Date?
    let targetHours: Double
    let planName: String
}

struct WatchFastingProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchFastingEntry {
        WatchFastingEntry(date: .now, isFasting: true, startTime: Date().addingTimeInterval(-8*3600), targetHours: 16, planName: "16:8")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WatchFastingEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchFastingEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.loopspur.honestfast") ?? .standard
        let isFasting = defaults.bool(forKey: "isFasting")
        let startTimestamp = defaults.double(forKey: "fastStartTime")
        let targetHours = defaults.double(forKey: "fastDurationHours")
        let planName = defaults.string(forKey: "planName") ?? "16:8"
        
        let startTime = startTimestamp > 0 ? Date(timeIntervalSince1970: startTimestamp) : nil
        
        let entry = WatchFastingEntry(
            date: .now,
            isFasting: isFasting,
            startTime: startTime,
            targetHours: targetHours > 0 ? targetHours : 16,
            planName: planName
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Circular Complication

struct CircularComplicationView: View {
    let entry: WatchFastingEntry
    
    private var progress: Double {
        guard entry.isFasting, let start = entry.startTime, entry.targetHours > 0 else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        return min(elapsed / (entry.targetHours * 3600), 1.0)
    }
    
    private var hoursElapsed: Int {
        guard let start = entry.startTime else { return 0 }
        return Int(Date().timeIntervalSince(start) / 3600)
    }
    
    var body: some View {
        ZStack {
            if entry.isFasting {
                Gauge(value: progress) {
                    Text("")
                } currentValueLabel: {
                    Text("\(hoursElapsed)h")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(.orange)
            } else {
                Gauge(value: 0) {
                    Text("")
                } currentValueLabel: {
                    Image(systemName: "fork.knife")
                        .font(.caption)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(.gray)
            }
        }
    }
}

// MARK: - Rectangular Complication

struct RectangularComplicationView: View {
    let entry: WatchFastingEntry
    
    private var elapsed: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return max(0, Date().timeIntervalSince(start))
    }
    
    private var progress: Double {
        guard entry.isFasting, entry.targetHours > 0 else { return 0 }
        return min(elapsed / (entry.targetHours * 3600), 1.0)
    }
    
    var body: some View {
        if entry.isFasting {
            VStack(alignment: .leading, spacing: 2) {
                Text("Fasting · \(Int(elapsed / 3600))h \(Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60))m")
                    .font(.caption)
                    .fontWeight(.medium)
                
                ProgressView(value: progress)
                    .tint(.orange)
                
                Text(entry.planName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("Honest Fast")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("Not fasting")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Inline Complication

struct InlineComplicationView: View {
    let entry: WatchFastingEntry
    
    private var hoursElapsed: Int {
        guard let start = entry.startTime else { return 0 }
        return Int(Date().timeIntervalSince(start) / 3600)
    }
    
    var body: some View {
        if entry.isFasting {
            Text("🔥 \(hoursElapsed)h fasting")
        } else {
            Text("Honest Fast")
        }
    }
}

// MARK: - Widget Bundle

struct FastingComplicationWidget: Widget {
    let kind = "FastingComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchFastingProvider()) { entry in
            CircularComplicationView(entry: entry)
        }
        .configurationDisplayName("Fasting Timer")
        .description("Track your fast on your watch face.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
    }
}
