import SwiftUI
import SwiftData
import Charts

struct HistoryScreen: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Query(sort: \FastRecord.startDate, order: .reverse) private var allFasts: [FastRecord]
    
    @State private var selectedMonth = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if allFasts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsSection
                            weeklyChart
                            calendarHeatMap
                            fastList
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("History")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: exportCSV(), preview: SharePreview("Fasting History", image: Image(systemName: "doc.text")))
                        .tint(Theme.accent)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("⏱")
                .font(.system(size: 48))
            Text("No fasts yet")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            Text("Complete your first fast to see your history here.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Stats
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(icon: "🔥", value: "\(fastingManager.currentStreak(fasts: allFasts))", label: "streak")
            StatCard(icon: "⏱", value: String(format: "%.1fh", averageFast), label: "average")
            StatCard(icon: "📊", value: "\(completedFasts.count)", label: "total")
        }
    }
    
    // MARK: - Weekly Bar Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            Chart(weeklyData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Hours", item.hours)
                )
                .foregroundStyle(
                    item.hours > 0
                        ? LinearGradient(colors: [Color(hex: "E8734A"), Color(hex: "F4A882")], startPoint: .bottom, endPoint: .top)
                        : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .bottom, endPoint: .top)
                )
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let h = value.as(Double.self) {
                            Text("\(Int(h))h")
                                .font(.caption2)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.gray.opacity(0.2))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(height: 140)
            .padding(12)
            .background(Theme.surface)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Calendar Heat Map
    
    private var calendarHeatMap: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.textSecondary)
                }
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            // Day headers
            let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
            HStack(spacing: 0) {
                ForEach(dayLabels.indices, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day grid
            let days = calendarDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    if let day {
                        let hours = fastingHours(for: day)
                        let isToday = Calendar.current.isDateInToday(day)
                        Circle()
                            .fill(heatColor(hours: hours))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if isToday {
                                    Circle().stroke(Theme.accent, lineWidth: 2)
                                }
                            }
                            .overlay {
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(.system(size: 10))
                                    .foregroundColor(hours > 0 ? .white : Theme.textSecondary)
                            }
                    } else {
                        Color.clear.frame(width: 28, height: 28)
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.surface)
        .cornerRadius(12)
    }
    
    // MARK: - Fast List
    
    private var fastList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Fasts")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            LazyVStack(spacing: 8) {
                ForEach(allFasts.prefix(20)) { fast in
                    fastRow(fast)
                }
            }
        }
    }
    
    private func fastRow(_ fast: FastRecord) -> some View {
        HStack {
            Circle()
                .fill(fast.isActive ? Theme.teal : (fast.completed ? Theme.success : Theme.accent))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fast.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                Text(fast.planName)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            if fast.isActive {
                Text("In progress")
                    .font(.caption)
                    .foregroundColor(Theme.teal)
            } else {
                Text(String(format: "%.0f:%02.0f",
                           floor(fast.durationHours),
                           (fast.durationHours.truncatingRemainder(dividingBy: 1)) * 60))
                    .font(.subheadline.monospacedDigit())
                    .fontWeight(.medium)
                    .foregroundColor(fast.completed ? Theme.success : Theme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .cornerRadius(12)
    }
    
    // MARK: - Helpers
    
    private var completedFasts: [FastRecord] { allFasts.filter { $0.completed } }
    
    private var averageFast: Double {
        guard !completedFasts.isEmpty else { return 0 }
        return completedFasts.reduce(0) { $0 + $1.durationHours } / Double(completedFasts.count)
    }
    
    private struct DayData {
        let day: Date
        let label: String
        let hours: Double
    }
    
    private var weeklyData: [DayData] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -mondayOffset, to: today)!
        
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: monday)!
            let hours = fastingHours(for: day)
            return DayData(day: day, label: labels[offset], hours: hours)
        }
    }
    
    private func fastingHours(for day: Date) -> Double {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: day)
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
        
        return allFasts
            .filter { fast in
                let end = fast.endDate ?? Date()
                return fast.startDate < dayEnd && end > dayStart
            }
            .reduce(0.0) { total, fast in
                let start = max(fast.startDate, dayStart)
                let end = min(fast.endDate ?? Date(), dayEnd)
                return total + max(0, end.timeIntervalSince(start) / 3600)
            }
    }
    
    private func heatColor(hours: Double) -> Color {
        switch hours {
        case 0: return Color.gray.opacity(0.15)
        case 0..<8: return Color(hex: "7BA686").opacity(0.3)
        case 8..<16: return Color(hex: "7BA686").opacity(0.6)
        default: return Color(hex: "7BA686")
        }
    }
    
    private func changeMonth(_ delta: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: delta, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
    
    private func calendarDays() -> [Date?] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: selectedMonth)!
        let firstOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday + 5) % 7 // Monday = 0
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            days.append(cal.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        return days
    }
    
    private func exportCSV() -> String {
        var csv = "date,protocol,start_time,end_time,duration_hours,completed\n"
        let fmt = ISO8601DateFormatter()
        for fast in allFasts {
            let end = fast.endDate.map { fmt.string(from: $0) } ?? ""
            csv += "\(fmt.string(from: fast.startDate)),\(fast.planName),\(fmt.string(from: fast.startDate)),\(end),\(String(format: "%.2f", fast.durationHours)),\(fast.completed)\n"
        }
        return csv
    }
}
