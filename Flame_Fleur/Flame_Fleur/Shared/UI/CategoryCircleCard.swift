import SwiftUI

struct CategoryCircleCard: View {
    let title: String
    let imageName: String?
    let diameter: CGFloat
    let titleFont: Font
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        imageName: String?,
        diameter: CGFloat = 102,
        titleFont: Font = AppTypography.categoryCircleLabel,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.imageName = imageName
        self.diameter = diameter
        self.titleFont = titleFont
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xxs) {
                FoodImagePlaceholder(imageName: imageName, style: .circle)
                    .frame(width: diameter * 0.86, height: diameter * 0.86)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppColors.burntOrange : AppColors.warmBorder, lineWidth: isSelected ? 2 : 1)
                    )

                Text(title)
                    .font(titleFont)
                    .foregroundStyle(isSelected ? AppColors.burntOrange : AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        CategoryCircleCard(title: "Italian", imageName: "pasta", isSelected: true)
        CategoryCircleCard(title: "Seafood", imageName: "salmon")
        CategoryCircleCard(title: "Beans", imageName: "bowl")
    }
    .padding()
    .background(AppColors.appBackground)
}
