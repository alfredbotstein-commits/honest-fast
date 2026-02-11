import SwiftUI

struct WatchTimerView: View {
    @AppStorage("isFasting", store: UserDefaults(suiteName: "group.com.loopspur.honestfast"))
    private var isFasting: Bool = false
    
    @AppStorage("fastStartTime", store: UserDefaults(suiteName: "group.com.loopspur.honestfast"))
    private var fastStartTime: Double = 0
    
    @AppStorage("fastDurationHours", store: UserDefaults(suiteName: "group.com.loopspur.honestfast"))
    private var fastDurationHours: Double = 16
    
    @AppStorage("planName", store: UserDefaults(suiteName: "group.com.loopspur.honestfast"))
    private var planName: String = "16:8"
    
    @StateObject private var connectivity = WatchConnectivityService.shared
    
    @State private var now = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var elapsed: TimeInterval {
        guard isFasting, fastStartTime > 0 else { return 0 }
        return now.timeIntervalSince(Date(timeIntervalSince1970: fastStartTime))
    }
    
    private var target: TimeInterval {
        fastDurationHours * 3600
    }
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(elapsed / target, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progress >= 1.0 ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 2) {
                    if isFasting {
                        Text(formatTime(elapsed))
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                        Text("of \(Int(fastDurationHours))h")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not Fasting")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            Button(action: toggleFast) {
                Text(isFasting ? "End Fast" : "Start Fast")
                    .font(.footnote.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isFasting ? .red : .green)
        }
        .onAppear {
            connectivity.activate()
            connectivity.onStateReceived = { dict in
                // @AppStorage will pick up changes from UserDefaults automatically
            }
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }
    
    private func toggleFast() {
        if isFasting {
            isFasting = false
            fastStartTime = 0
            connectivity.sendStateToPhone(
                isFasting: false,
                startTime: 0,
                targetHours: fastDurationHours,
                planName: planName
            )
        } else {
            let startTime = Date().timeIntervalSince1970
            fastStartTime = startTime
            isFasting = true
            connectivity.sendStateToPhone(
                isFasting: true,
                startTime: startTime,
                targetHours: fastDurationHours,
                planName: planName
            )
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let h = Int(interval) / 3600
        let m = (Int(interval) % 3600) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

#Preview {
    WatchTimerView()
}
