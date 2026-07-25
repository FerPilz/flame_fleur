import SwiftUI

struct OnboardingWelcomeView: View {
    let onGetStarted: () -> Void
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = max(geometry.safeAreaInsets.bottom, AppSpacing.md)
            let imageOffset = geometry.size.height * 0.104

            ZStack {
                AppColors.porcelainCream.ignoresSafeArea()

                Image("onboarding_welcome_hero 1")
                    .resizable()
                    .scaledToFill()
                    .accessibilityHidden(true)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .offset(y: imageOffset)

                VStack(spacing: 0) {
                    OnboardingTopBar(currentStep: 1, totalSteps: 4, onSkip: onSkip)
                        .padding(.horizontal, OnboardingLayout.horizontalInset)
                        .padding(.top, OnboardingLayout.topBarTopPadding(safeAreaTop: geometry.safeAreaInsets.top))

                    VStack(spacing: AppSpacing.md) {
                        Text("Welcome to AllSpiced")
                            .font(.system(size: 40, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.deepBasil)
                            .multilineTextAlignment(.center)

                        Text("Discover meals, plan your week,\nand build your grocery cart in seconds.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(7)
                    }
                    .padding(.horizontal, OnboardingLayout.horizontalInset)
                    .padding(.top, OnboardingLayout.welcomeTitleTopSpacing)

                    Spacer()

                    OnboardingPrimaryButton(title: "Get Started", action: onGetStarted)
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.xl)
                        .padding(.bottom, bottomInset + AppSpacing.xs)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
