import SwiftUI
import SwiftData

struct HistoryScreen: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Query(sort: \FastRecord.startDate, order: .reverse) private var allFasts: [FastRecord]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if allFasts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Stats
                            statsSection
                            
                            // Fast list
                            fastList
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("History")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
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
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "🔥",
                value: "\(fastingManager.currentStreak(fasts: allFasts))",
                label: "streak"
            )
            StatCard(
                icon: "⏱",
                value: String(format: "%.1fh", averageFast),
                label: "average"
            )
            StatCard(
                icon: "📊",
                value: "\(completedFasts.count)",
                label: "total"
            )
        }
    }
    
    private var fastList: some View {
        LazyVStack(spacing: 8) {
            ForEach(allFasts) { fast in
                fastRow(fast)
            }
        }
    }
    
    private func fastRow(_ fast: FastRecord) -> some View {
        HStack {
            // Status dot
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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(fast.completed ? Theme.success : Theme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .cornerRadius(12)
    }
    
    // MARK: - Computed
    
    private var completedFasts: [FastRecord] {
        allFasts.filter { $0.completed }
    }
    
    private var averageFast: Double {
        guard !completedFasts.isEmpty else { return 0 }
        return completedFasts.reduce(0) { $0 + $1.durationHours } / Double(completedFasts.count)
    }
}
