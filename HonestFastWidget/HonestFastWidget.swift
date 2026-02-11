import WidgetKit
import SwiftUI

struct FastingEntry: TimelineEntry {
    let date: Date
    let isFasting: Bool
    let elapsed: TimeInterval
    let targetHours: Double
}

struct FastingProvider: TimelineProvider {
    func placeholder(in context: Context) -> FastingEntry {
        FastingEntry(date: .now, isFasting: true, elapsed: 3600 * 8, targetHours: 16)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FastingEntry) -> Void) {
        let entry = FastingEntry(date: .now, isFasting: true, elapsed: 3600 * 8, targetHours: 16)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.loopspur.honestfast")
        let isFasting = defaults?.bool(forKey: "isFasting") ?? false
        let startTime = defaults?.double(forKey: "fastStartTime") ?? 0
        let targetHours = defaults?.double(forKey: "fastDurationHours") ?? 16
        
        let now = Date()
        let elapsed = isFasting && startTime > 0 ? now.timeIntervalSince(Date(timeIntervalSince1970: startTime)) : 0
        
        let entry = FastingEntry(date: now, isFasting: isFasting, elapsed: elapsed, targetHours: targetHours)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct FastingWidgetView: View {
    var entry: FastingEntry
    
    private var progress: Double {
        guard entry.targetHours > 0 else { return 0 }
        return min(entry.elapsed / (entry.targetHours * 3600), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progress >= 1.0 ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    if entry.isFasting {
                        Text("\(Int(entry.elapsed / 3600))h")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                        Text("\(Int(entry.targetHours))h goal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(4)
            
            Text(entry.isFasting ? "Fasting" : "Eating")
                .font(.caption2.bold())
                .foregroundStyle(entry.isFasting ? .orange : .green)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct HonestFastWidget: Widget {
    let kind = "HonestFastWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingProvider()) { entry in
            FastingWidgetView(entry: entry)
        }
        .configurationDisplayName("Fasting Timer")
        .description("Track your current fast at a glance.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
    }
}
