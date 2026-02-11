import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var fastingManager: FastingManager
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo ring
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accentDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                }
                
                VStack(spacing: 8) {
                    Text("Honest Fast")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Just fasting. No tricks.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                VStack(spacing: 8) {
                    Text("Pick your plan to start.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Plan selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FastingPlan.plans) { plan in
                            PlanCard(
                                plan: plan,
                                isSelected: fastingManager.selectedPlan.id == plan.id,
                                onTap: {
                                    fastingManager.selectedPlan = plan
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Custom hours if needed
                if fastingManager.selectedPlan.id == "Custom" {
                    VStack(spacing: 12) {
                        Stepper(
                            "Fast: \(Int(fastingManager.customFastHours))h",
                            value: $fastingManager.customFastHours,
                            in: 1...23
                        )
                        .foregroundColor(Theme.textPrimary)
                        
                        Stepper(
                            "Eat: \(Int(fastingManager.customEatHours))h",
                            value: $fastingManager.customEatHours,
                            in: 1...23
                        )
                        .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // CTA
                Button {
                    onComplete()
                    fastingManager.startFast()
                } label: {
                    Text("Start Fasting")
                        .font(.headline)
                        .foregroundColor(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.accent)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}
