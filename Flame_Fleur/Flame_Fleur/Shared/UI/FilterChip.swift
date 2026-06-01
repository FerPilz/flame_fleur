import SwiftUI

struct FilterChip: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        isSelected: Bool,
        selectedColor: Color = AppColors.burntOrange,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xxs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(AppTypography.tabLabel)
                }

                Text(title)
                    .font(AppTypography.tabLabel)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: 30)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? selectedColor : AppColors.elevatedCardBackground)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isSelected ? selectedColor : AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        FilterChip("All", isSelected: true) {}
        FilterChip("Vegetarian", isSelected: false) {}
    }
    .padding()
    .background(AppColors.appBackground)
}
