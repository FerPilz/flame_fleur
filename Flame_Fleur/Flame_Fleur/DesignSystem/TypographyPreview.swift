import SwiftUI

struct TypographyPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ALLSPICED")
                .font(AppTypography.brandTitle)

            Text("Featured")
                .font(AppTypography.sectionTitle)

            Text("Community")
                .font(AppTypography.sectionTitle)

            Text("Top Picks for You")
                .font(AppTypography.sectionTitle)

            Text("Spicy Tomato & Basil Pasta")
                .font(AppTypography.cardTitle)

            Text("Breakfast")
                .font(AppTypography.categoryCircleLabel)
            Text("Spicy Tomato & Basil Pasta")
                .font(AppTypography.heroTitle)
        }
        .padding(24)
        .background(AppColors.porcelainCream)
    }
}

#Preview("Typography Only") {
    TypographyPreview()
}
