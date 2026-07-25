import SwiftUI

enum OnboardingLayout {
    static let horizontalInset = AppSpacing.screenHorizontal
    static let headerTopSpacing: CGFloat = 0
    static let headerBottomSpacing = AppSpacing.xxs
    static let contentTopSpacing = AppSpacing.xxs
    static let contentSectionSpacing: CGFloat = 10
    static let welcomeTitleTopSpacing: CGFloat = 10

    static func topBarTopPadding(safeAreaTop: CGFloat) -> CGFloat {
        safeAreaTop + headerTopSpacing
    }
}

struct OnboardingScaffold<Content: View, Footer: View>: View {
    let currentStep: Int
    let totalSteps: Int
    let onSkip: () -> Void
    let content: Content
    let footer: Footer

    init(
        currentStep: Int,
        totalSteps: Int = 4,
        onSkip: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.onSkip = onSkip
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.porcelainCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    OnboardingTopBar(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onSkip: onSkip
                    )
                    .padding(.horizontal, OnboardingLayout.horizontalInset)
                    .padding(.top, OnboardingLayout.topBarTopPadding(safeAreaTop: geometry.safeAreaInsets.top))
                    .padding(.bottom, OnboardingLayout.headerBottomSpacing)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: OnboardingLayout.contentSectionSpacing) {
                            content
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, OnboardingLayout.horizontalInset)
                        .padding(.top, OnboardingLayout.contentTopSpacing)
                        .padding(.bottom, AppSpacing.lg)
                    }

                    footer
                        .padding(.horizontal, OnboardingLayout.horizontalInset)
                        .padding(.top, AppSpacing.sm)
                        .padding(.bottom, AppSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [
                                    AppColors.porcelainCream.opacity(0),
                                    AppColors.porcelainCream.opacity(0.72),
                                    AppColors.porcelainCream
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        }
    }
}

struct OnboardingTopBar: View {
    let currentStep: Int
    let totalSteps: Int
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            OnboardingProgressIndicator(currentStep: currentStep, totalSteps: totalSteps)

            HStack {
                Spacer()

                Button("Skip", action: onSkip)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.deepBasil)
            }
        }
        .offset(y: -AppSpacing.xxxl)
        .frame(height: 32)
    }
}

struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule(style: .continuous)
                    .fill(step <= currentStep ? AppColors.basilGreen : AppColors.warmBorder.opacity(0.55))
                    .frame(width: 40, height: 6)
            }
        }
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        PrimaryButton(
            title,
            backgroundColor: AppColors.basilGreen,
            foregroundColor: AppColors.elevatedCardBackground,
            height: 58,
            font: AppTypography.button,
            action: action
        )
    }
}

struct OnboardingSecondaryTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.deepBasil)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xs)
        }
        .buttonStyle(.plain)
    }
}

struct SelectableOnboardingCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    let content: Content

    init(
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                        .fill(AppColors.elevatedCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.extraLarge, style: .continuous)
                        .strokeBorder(isSelected ? AppColors.basilGreen : AppColors.warmBorder.opacity(0.85), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: 0, y: AppShadow.cardYOffset)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SelectableCuisineCard: View {
    let title: String
    let imageName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableOnboardingCard(isSelected: isSelected, action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    FoodImagePlaceholder(imageName: imageName, style: .card)
                        .frame(height: 110)

                    HStack {
                        Text(title)
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(Capsule(style: .continuous).fill(AppColors.porcelainCream))

                        Spacer(minLength: 0)
                    }
                    .padding(AppSpacing.sm)
                }
                .padding(AppSpacing.xxs)

                selectionBadge(isSelected: isSelected)
                    .padding(AppSpacing.sm)
            }
        }
    }
}

struct SelectableGoalCard: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableOnboardingCard(isSelected: isSelected, action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? AppColors.softOlive : AppColors.porcelainCream)
                            .frame(width: 50, height: 50)

                        Image(systemName: systemImage)
                            .font(.system(size: 23, weight: .semibold))
                            .foregroundStyle(AppColors.basilGreen)
                    }

                    Text(title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.sm)
                .frame(minHeight: 132)

                selectionBadge(isSelected: isSelected)
                    .padding(AppSpacing.xs)
            }
        }
        .padding(.horizontal, AppSpacing.xs)
    }
}

private func selectionBadge(isSelected: Bool) -> some View {
    ZStack {
        Circle()
            .fill(isSelected ? AppColors.basilGreen : AppColors.porcelainCream)
            .frame(width: 28, height: 28)

        Image(systemName: isSelected ? "checkmark" : "circle")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.warmBorder)
    }
    .overlay(
        Circle()
            .stroke(isSelected ? AppColors.basilGreen : AppColors.warmBorder.opacity(0.85), lineWidth: 1)
    )
}
