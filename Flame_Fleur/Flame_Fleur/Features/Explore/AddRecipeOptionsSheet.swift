import SwiftUI

struct AddRecipeOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAddManually: () -> Void
    let onImportFromWebsite: () -> Void

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Choose how you want to create a recipe.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)

                    SurfaceCard(
                        backgroundColor: AppColors.elevatedCardBackground,
                        borderColor: AppColors.warmBorder,
                        cornerRadius: AppRadius.large,
                        contentPadding: AppSpacing.sm,
                        showsShadow: false
                    ) {
                        VStack(spacing: AppSpacing.sm) {
                            optionButton(
                                title: "Add Manually",
                                subtitle: "Start from a blank recipe form.",
                                systemImage: "square.and.pencil",
                                isRecipeStyle: false
                            ) {
                                onAddManually()
                                dismiss()
                            }

                            optionButton(
                                title: "Import from Website",
                                subtitle: "Paste a recipe link and let CookFlow read it.",
                                systemImage: "link",
                                isRecipeStyle: true
                            ) {
                                onImportFromWebsite()
                                dismiss()
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.lg)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            HStack {
                IconCircleButton(
                    systemName: "xmark",
                    accessibilityLabel: "Cancel",
                    size: AppTopActionMetrics.buttonSize,
                    action: { dismiss() }
                )

                Spacer()
            }

            Text("Add Recipe")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(height: 44)
    }

    private func optionButton(
        title: String,
        subtitle: String,
        systemImage: String,
        isRecipeStyle: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isRecipeStyle ? AppColors.burntOrange : AppColors.darkOlive)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AppColors.appBackground))
                    .overlay(Circle().stroke(AppColors.warmBorder, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text(subtitle)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(isRecipeStyle ? AppColors.softOrange.opacity(0.42) : AppColors.softOlive.opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddRecipeOptionsSheet(onAddManually: {}, onImportFromWebsite: {})
}
