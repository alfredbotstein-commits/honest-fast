import SwiftUI

struct FastingStageBadge: View {
    let stage: FastingStage
    let startTime: Date?
    let endTime: Date?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(stage.icon)
                Text(stage.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(stage.color)
            }
            
            if let start = startTime {
                HStack(spacing: 16) {
                    Label(start.formatted(date: .omitted, time: .shortened), systemImage: "play.fill")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    
                    if let end = endTime {
                        Label(end.formatted(date: .omitted, time: .shortened), systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .cornerRadius(12)
    }
}
