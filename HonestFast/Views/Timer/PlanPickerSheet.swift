import SwiftUI

struct PlanPickerSheet: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Your Plan")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary)
                    
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
                    
                    // Custom hours picker
                    if fastingManager.selectedPlan.id == "Custom" {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Fast hours")
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Stepper(
                                    "\(Int(fastingManager.customFastHours))h",
                                    value: $fastingManager.customFastHours,
                                    in: 1...23,
                                    step: 1
                                )
                                .foregroundColor(Theme.textPrimary)
                            }
                            
                            HStack {
                                Text("Eat hours")
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Stepper(
                                    "\(Int(fastingManager.customEatHours))h",
                                    value: $fastingManager.customEatHours,
                                    in: 1...23,
                                    step: 1
                                )
                                .foregroundColor(Theme.textPrimary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accent)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.accent)
                }
            }
        }
    }
}
