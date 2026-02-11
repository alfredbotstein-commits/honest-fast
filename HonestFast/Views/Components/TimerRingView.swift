import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let isComplete: Bool
    var diameter: CGFloat = 200
    
    private let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Theme.timerTrack, lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)
            
            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    isComplete ? completeGradient : progressGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            // Leading edge glow
            if progress > 0 && progress < 1 && !isComplete {
                Circle()
                    .fill(Theme.accent.opacity(0.6))
                    .frame(width: lineWidth * 2, height: lineWidth * 2)
                    .blur(radius: 4)
                    .offset(y: -diameter / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
            }
        }
    }
    
    private var progressGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [Theme.accent, Theme.accentDeep]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360 * progress)
        )
    }
    
    private var completeGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [Theme.success, Theme.teal]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
}
