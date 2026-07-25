import SwiftUI

struct OnboardingGoalPreferencesView: View {
    let options: [OnboardingGoalOption]
    let selectedGoalIDs: Set<String>
    let onToggleGoal: (String) -> Void
    let onContinue: () -> Void
    let onSkipForNow: () -> Void
    let onSkip: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.sm),
        GridItem(.flexible(), spacing: AppSpacing.sm)
    ]

    var body: some View {
        OnboardingScaffold(currentStep: 3, onSkip: onSkip) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("What are you cooking for?")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.deepBasil)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text("Choose what matters most this week.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColors.secondaryText)
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(options) { option in
                    SelectableGoalCard(
                        title: option.title,
                        systemImage: option.systemImage,
                        isSelected: selectedGoalIDs.contains(option.id),
                        action: { onToggleGoal(option.id) }
                    )
                }
            }
        } footer: {
            VStack(spacing: AppSpacing.xs) {
                OnboardingPrimaryButton(title: "Continue", action: onContinue)
                OnboardingSecondaryTextButton(title: "Skip for now", action: onSkipForNow)
            }
        }
    }
}
