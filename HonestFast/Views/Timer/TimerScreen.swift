import SwiftUI
import SwiftData

struct TimerScreen: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Query(sort: \FastRecord.startDate, order: .reverse) private var allFasts: [FastRecord]
    
    @State private var showPlanPicker = false
    @State private var animateStart = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Plan header
                planHeader
                
                Spacer()
                
                // Timer area
                if fastingManager.isFasting || fastingManager.isComplete {
                    activeTimerView
                } else {
                    idleTimerView
                }
                
                Spacer()
                
                // Stats row
                if fastingManager.isFasting || fastingManager.isComplete {
                    statsRow
                }
                
                // End fast button
                if fastingManager.isFasting {
                    endFastButton
                }
                
                // Dismiss complete state
                if fastingManager.isComplete {
                    Button("Done") {
                        fastingManager.currentFast = nil
                        fastingManager.isComplete = false
                        fastingManager.progress = 0
                    }
                    .font(.headline)
                    .foregroundColor(Theme.accent)
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showPlanPicker) {
            PlanPickerSheet()
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Plan Header
    
    private var planHeader: some View {
        Button {
            if !fastingManager.isFasting {
                showPlanPicker = true
            }
        } label: {
            HStack(spacing: 6) {
                Text("Current Plan:")
                    .foregroundColor(Theme.textSecondary)
                Text(fastingManager.selectedPlan.name)
                    .foregroundColor(Theme.textPrimary)
                    .fontWeight(.semibold)
                if !fastingManager.isFasting {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .font(.subheadline)
        }
        .disabled(fastingManager.isFasting)
        .padding(.top, 12)
    }
    
    // MARK: - Active Timer
    
    private var activeTimerView: some View {
        VStack(spacing: 20) {
            ZStack {
                TimerRingView(
                    progress: fastingManager.progress,
                    isComplete: fastingManager.isComplete
                )
                
                VStack(spacing: 4) {
                    if fastingManager.isComplete {
                        Text("Complete! 🎉")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.success)
                    } else {
                        Text(formatTime(fastingManager.timeRemaining))
                            .font(.system(size: 72, weight: .light, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(Theme.textPrimary)
                            .tracking(-2)
                        
                        Text("remaining")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .tracking(1)
                    }
                }
            }
            
            FastingStageBadge(
                stage: fastingManager.currentStage,
                startTime: fastingManager.startTime,
                endTime: fastingManager.endTime
            )
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .opacity
            ))
            .animation(.easeInOut(duration: 0.3), value: fastingManager.currentStage)
        }
    }
    
    // MARK: - Idle Timer
    
    private var idleTimerView: some View {
        VStack(spacing: 24) {
            ZStack {
                TimerRingView(progress: 0, isComplete: false)
                
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        animateStart = true
                        fastingManager.startFast()
                    }
                } label: {
                    Text("Start Fast")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.background)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .cornerRadius(25)
                }
            }
            
            Text("Tap to begin your \(fastingManager.selectedPlan.name) fast")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "🔥",
                value: "\(fastingManager.currentStreak(fasts: allFasts))",
                label: "streak"
            )
            StatCard(
                icon: "⏱",
                value: "\(fastingManager.fastsThisWeek(fasts: allFasts))",
                label: "this wk"
            )
        }
    }
    
    // MARK: - End Fast
    
    private var endFastButton: some View {
        Button {
            fastingManager.endFast()
        } label: {
            Text("END FAST EARLY")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.surface)
                .cornerRadius(12)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}
