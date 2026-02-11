import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var fastingManager: FastingManager
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var ringDrawProgress: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                planPage.tag(1)
                notificationPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
    
    // MARK: - Page 1: Welcome
    
    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated broken circle
            ZStack {
                Circle()
                    .trim(from: 0, to: ringDrawProgress * 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accentDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
            }
            
            VStack(spacing: 8) {
                Text("Honest Fast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .opacity(titleOpacity)
                
                Text("No subscriptions. No ads. No account.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .opacity(subtitleOpacity)
            }
            
            Spacer()
            
            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
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
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                ringDrawProgress = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(1.1)) {
                subtitleOpacity = 1.0
            }
            HapticService.startFast()
        }
    }
    
    // MARK: - Page 2: Pick Plan
    
    private var planPage: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)
            
            Text("How do you fast?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text("You can change this later in Settings.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            // Plan grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(FastingPlan.plans) { plan in
                    PlanCard(
                        plan: plan,
                        isSelected: fastingManager.selectedPlan.id == plan.id,
                        onTap: {
                            HapticService.startFast()
                            fastingManager.selectedPlan = plan
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            if fastingManager.selectedPlan.id == "Custom" {
                VStack(spacing: 12) {
                    Stepper("Fast: \(Int(fastingManager.customFastHours))h",
                            value: $fastingManager.customFastHours, in: 1...23)
                        .foregroundColor(Theme.textPrimary)
                    Stepper("Eat: \(Int(fastingManager.customEatHours))h",
                            value: $fastingManager.customEatHours, in: 1...23)
                        .foregroundColor(Theme.textPrimary)
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("Continue")
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
    
    // MARK: - Page 3: Notifications
    
    private var notificationPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "bell.badge")
                .font(.system(size: 56))
                .foregroundColor(Theme.accent)
            
            VStack(spacing: 8) {
                Text("Stay on track")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                Text("We'll let you know when your fast starts and ends. That's it. No spam.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                NotificationService.shared.requestPermission()
                completeOnboarding()
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
            
            Button {
                completeOnboarding()
            } label: {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.bottom, 16)
        }
    }
    
    private func completeOnboarding() {
        HapticService.fastComplete()
        onComplete()
    }
}
