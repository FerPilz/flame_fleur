import SwiftUI

struct OnboardingCuisinePreferencesView: View {
    let options: [OnboardingCuisineOption]
    let selectedCuisineIDs: Set<String>
    let onToggleCuisine: (String) -> Void
    let onContinue: () -> Void
    let onSkipForNow: () -> Void
    let onSkip: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.sm),
        GridItem(.flexible(), spacing: AppSpacing.sm)
    ]

    var body: some View {
        OnboardingScaffold(currentStep: 2, onSkip: onSkip) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("What cuisines do you enjoy?")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.deepBasil)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text("Pick a few so we can shape your recipe ideas.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(AppColors.secondaryText)
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(options) { option in
                    SelectableCuisineCard(
                        title: option.title,
                        imageName: option.imageName,
                        isSelected: selectedCuisineIDs.contains(option.id),
                        action: { onToggleCuisine(option.id) }
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
