import SwiftUI

struct RecipeHeroHeader: View {
    let recipe: Recipe
    let isFavorite: Bool
    let shareText: String
    let showsBackButton: Bool
    let onCartTap: (() -> Void)?
    let onBack: () -> Void
    let onFavoriteTap: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                heroSurface(in: proxy)

                LinearGradient(
                    colors: [
                        AppColors.shadow.opacity(0.20),
                        AppColors.shadow.opacity(0.04),
                        AppColors.shadow.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack(spacing: AppSpacing.sm) {
                    if showsBackButton {
                        Button(action: onBack) {
                            RecipeHeroActionIcon(systemName: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Back"))
                    }

                    Spacer()

                    ShareLink(item: shareText) {
                        RecipeHeroActionIcon(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Share recipe"))

                    Button(action: onFavoriteTap) {
                        RecipeHeroActionIcon(
                            systemName: isFavorite ? "heart.fill" : "heart",
                            foregroundColor: isFavorite ? AppColors.error : AppColors.olive
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(isFavorite ? "Unsave recipe" : "Save recipe"))

                    if let onCartTap {
                        Button(action: onCartTap) {
                            RecipeHeroActionIcon(systemName: "cart")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Open shopping cart"))
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, max(proxy.safeAreaInsets.top + AppSpacing.sm, AppTopActionMetrics.minimumTopOffset))
            }
        }
    }

    private func heroSurface(in proxy: GeometryProxy) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.warmCream,
                    AppColors.softOrange.opacity(0.82),
                    AppColors.olive.opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            FoodImagePlaceholder(imageName: recipe.imageName, style: .hero)
                .frame(width: proxy.size.width * 1.12, height: proxy.size.height * 1.02)
                .blur(radius: 18)
                .opacity(0.42)
                .scaleEffect(1.05)

            FoodImagePlaceholder(imageName: recipe.imageName, style: .hero)
                .frame(width: proxy.size.width * 0.92, height: proxy.size.height * 0.72)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                        .stroke(AppColors.elevatedCardBackground.opacity(0.28), lineWidth: 1)
                )
                .offset(y: proxy.size.height * 0.13)
                .opacity(0.88)

            LinearGradient(
                colors: [
                    AppColors.elevatedCardBackground.opacity(0.02),
                    AppColors.shadow.opacity(0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .clipped()
    }
}

private struct RecipeHeroActionIcon: View {
    let systemName: String
    let foregroundColor: Color

    init(
        systemName: String,
        foregroundColor: Color = AppColors.olive
    ) {
        self.systemName = systemName
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        Circle()
            .fill(AppColors.elevatedCardBackground.opacity(0.94))
            .overlay(
                Circle()
                    .stroke(AppColors.warmBorder.opacity(0.76), lineWidth: 1)
            )
            .frame(width: AppTopActionMetrics.buttonSize, height: AppTopActionMetrics.buttonSize)
            .overlay(
                Image(systemName: systemName)
                    .font(AppTypography.callout)
                    .foregroundStyle(foregroundColor)
            )
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: 0, y: AppShadow.cardYOffset)
    }
}

#Preview {
    RecipeHeroHeader(
        recipe: RecipeRepository.shared.allRecipes[0],
        isFavorite: true,
        shareText: "Check out this recipe in Flame & Fleur.",
        showsBackButton: true,
        onCartTap: {},
        onBack: {},
        onFavoriteTap: {}
    )
    .frame(height: 300)
}
