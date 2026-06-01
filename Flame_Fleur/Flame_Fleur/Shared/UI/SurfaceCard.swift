import SwiftUI

struct SurfaceCard<Content: View>: View {
    let backgroundColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    let contentPadding: CGFloat
    let showsShadow: Bool
    let content: Content

    init(
        backgroundColor: Color = AppColors.elevatedCardBackground,
        borderColor: Color = AppColors.warmBorder,
        cornerRadius: CGFloat = AppRadius.extraLarge,
        contentPadding: CGFloat = AppSpacing.md,
        showsShadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.contentPadding = contentPadding
        self.showsShadow = showsShadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(
                color: showsShadow ? AppShadow.cardColor : .clear,
                radius: showsShadow ? AppShadow.cardRadius : 0,
                x: 0,
                y: showsShadow ? AppShadow.cardYOffset : 0
            )
    }
}

#Preview {
    SurfaceCard {
        Text("A warm, quiet surface for editorial cooking content.")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.textPrimary)
    }
    .padding()
    .background(AppColors.appBackground)
}
