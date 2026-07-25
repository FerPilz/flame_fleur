import SwiftUI

struct SettingsSelectionOption: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?

    init(id: String, title: String, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

struct SettingsSelectionSheet: View {
    let title: String
    let subtitle: String?
    let options: [SettingsSelectionOption]
    let allowsMultiple: Bool
    let onSelect: (String) -> Void
    let onSave: (Set<String>) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIDs: Set<String>

    init(
        title: String,
        subtitle: String? = nil,
        options: [SettingsSelectionOption],
        selectedIDs: Set<String>,
        allowsMultiple: Bool = false,
        onSelect: @escaping (String) -> Void,
        onSave: @escaping (Set<String>) -> Void = { _ in }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.allowsMultiple = allowsMultiple
        self.onSelect = onSelect
        self.onSave = onSave
        _selectedIDs = State(initialValue: selectedIDs)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        header

                        VStack(spacing: AppSpacing.xs) {
                            ForEach(options) { option in
                                optionRow(option)
                            }
                        }
                    }
                }

                if allowsMultiple {
                    PrimaryButton("Apply", style: .olive, height: 44) {
                        onSave(selectedIDs)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.heroTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            IconCircleButton(
                systemName: "xmark",
                accessibilityLabel: "Close",
                size: 30,
                action: { dismiss() }
            )
        }
    }

    private func optionRow(_ option: SettingsSelectionOption) -> some View {
        let isSelected = selectedIDs.contains(option.id)

        return Button {
            if allowsMultiple {
                if isSelected {
                    selectedIDs.remove(option.id)
                } else {
                    selectedIDs.insert(option.id)
                }
            } else {
                onSelect(option.id)
                dismiss()
            }
        } label: {
            SurfaceCard(
                backgroundColor: AppColors.elevatedCardBackground,
                borderColor: isSelected ? AppColors.olive.opacity(0.52) : AppColors.warmBorder,
                cornerRadius: AppRadius.large,
                contentPadding: AppSpacing.sm
            ) {
                HStack(spacing: AppSpacing.sm) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(option.title)
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)

                        if let subtitle = option.subtitle {
                            Text(subtitle)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(isSelected ? AppColors.olive : AppColors.tertiaryText)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SettingsSelectionSheet(
        title: "Units",
        options: [
            SettingsSelectionOption(id: "metric", title: "Metric", subtitle: "kg, \u{00B0}C"),
            SettingsSelectionOption(id: "imperial", title: "Imperial", subtitle: "lb, \u{00B0}F")
        ],
        selectedIDs: ["metric"],
        onSelect: { _ in }
    )
}
