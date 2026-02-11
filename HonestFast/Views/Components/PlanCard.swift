import SwiftUI

struct PlanCard: View {
    let plan: FastingPlan
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text(plan.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? Theme.background : Theme.textPrimary)
            
            if plan.id != "Custom" {
                Text("\(Int(plan.fastHours))hr fast · \(Int(plan.eatHours))hr eat")
                    .font(.caption2)
                    .foregroundColor(isSelected ? Theme.background.opacity(0.8) : Theme.textSecondary)
            }
            
            Text(plan.description)
                .font(.caption2)
                .foregroundColor(isSelected ? Theme.background.opacity(0.7) : Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 130)
        .background(isSelected ? Theme.accent : Theme.surface)
        .cornerRadius(16)
        .onTapGesture(perform: onTap)
    }
}
