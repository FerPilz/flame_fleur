import SwiftUI

struct CategoryCircleCard: View {
    let title: String
    let imageName: String?
    let diameter: CGFloat
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        imageName: String?,
        diameter: CGFloat = 100,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.imageName = imageName
        self.diameter = diameter
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                FoodImagePlaceholder(imageName: imageName, style: .circle)
                    .frame(width: diameter, height: diameter)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppColors.burntOrange : AppColors.warmBorder, lineWidth: isSelected ? 2 : 1)
                    )

                Text(title)
                    .font(AppTypography.tabLabel)
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
