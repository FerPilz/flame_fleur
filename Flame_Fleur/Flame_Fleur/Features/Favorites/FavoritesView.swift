import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionHeaderView(
                        "Favorites",
                        subtitle: "Saved recipes and beloved ideas will be easy to return to."
                    )

                    SurfaceCard {
                        Text("Keep the dishes, notes, and little discoveries that feel like part of your own table.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineSpacing(3)
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FavoritesView()
}
