import SwiftUI

enum RecipeScreenHeroLayout {
    static let minHeroHeight: CGFloat = 325
    static let maxHeroHeight: CGFloat = 416
    static let heroHeightRatio: CGFloat = 0.455
    static let panelOverlap: CGFloat = 100
    static let topControlsPadding: CGFloat = 24
}

struct RecipeHeroHeader: View {
    let recipe: Recipe
    let isFavorite: Bool
    let shareText: String
    let showsBackground: Bool
    let showsBackButton: Bool
    let showsShareButton: Bool
    let showsBrandTitle: Bool
    let showsFavoriteButton: Bool
    let topControlsPadding: CGFloat
    let onCartTap: (() -> Void)?
    let cartBadgeValue: Int?
    let onBack: () -> Void
    let onFavoriteTap: () -> Void

    init(
        recipe: Recipe,
        isFavorite: Bool,
        shareText: String,
        showsBackground: Bool = true,
        showsBackButton: Bool,
        showsShareButton: Bool = true,
        showsBrandTitle: Bool = true,
        showsFavoriteButton: Bool = true,
        topControlsPadding: CGFloat? = nil,
        onCartTap: (() -> Void)?,
        cartBadgeValue: Int?,
        onBack: @escaping () -> Void,
        onFavoriteTap: @escaping () -> Void
    ) {
        self.recipe = recipe
        self.isFavorite = isFavorite
        self.shareText = shareText
        self.showsBackground = showsBackground
        self.showsBackButton = showsBackButton
        self.showsShareButton = showsShareButton
        self.showsBrandTitle = showsBrandTitle
        self.showsFavoriteButton = showsFavoriteButton
        self.topControlsPadding = topControlsPadding ?? AppTopActionMetrics.minimumTopOffset
        self.onCartTap = onCartTap
        self.cartBadgeValue = cartBadgeValue
        self.onBack = onBack
        self.onFavoriteTap = onFavoriteTap
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                if showsBackground {
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
                }

                VStack(spacing: showsBrandTitle ? AppSpacing.xs : 0) {
                    if showsBrandTitle {
                        AppBrandTitle()
                            .frame(height: 44)
                    }

                    HStack(spacing: AppSpacing.sm) {
                        if showsBackButton {
                        Button(action: onBack) {
                            RecipeHeroActionIcon(systemName: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel(Text("Back"))
                    }

                        Spacer()

                        if showsShareButton {
                        ShareLink(item: shareText) {
                            RecipeHeroActionIcon(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Share recipe"))
                        }

                        if showsFavoriteButton {
                            Button(action: onFavoriteTap) {
                                RecipeHeroActionIcon(
                                    systemName: isFavorite ? "heart.fill" : "heart",
                                    foregroundColor: isFavorite ? AppColors.error : AppColors.olive
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(isFavorite ? "Unsave recipe" : "Save recipe"))
                        }

                        if let onCartTap {
                            Button(action: onCartTap) {
                                RecipeHeroActionIcon(
                                    systemName: cartBadgeValue == nil ? "cart" : "cart.fill",
                                    badgeValue: cartBadgeValue
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("Open shopping cart"))
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, max(proxy.safeAreaInsets.top, topControlsPadding))
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
                .frame(width: proxy.size.width + 8, height: proxy.size.height + 8)
                .blur(radius: 18)
                .opacity(0.42)
                .offset(x: -4, y: -4)

            FoodImagePlaceholder(imageName: recipe.imageName, style: .hero)
                .frame(width: proxy.size.width + 8, height: proxy.size.height + 8)
                .offset(x: -4, y: -4)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                        .stroke(AppColors.elevatedCardBackground.opacity(0.28), lineWidth: 1)
                )
                .opacity(0.92)

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
    let badgeValue: Int?

    init(
        systemName: String,
        foregroundColor: Color = AppColors.olive,
        badgeValue: Int? = nil
    ) {
        self.systemName = systemName
        self.foregroundColor = foregroundColor
        self.badgeValue = badgeValue
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
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

            if let badgeValue, badgeValue > 0 {
                badgeLabel(for: badgeValue)
                    .offset(x: 4, y: -4)
            }
        }
    }

    @ViewBuilder
    private func badgeLabel(for badgeValue: Int) -> some View {
        let text = formattedBadgeValue(badgeValue)

        Text(text)
            .font(.system(size: 8.5, weight: .bold))
            .foregroundStyle(AppColors.elevatedCardBackground)
            .padding(.horizontal, text.count > 1 ? 5 : 3)
            .frame(minWidth: badgeWidth(for: text), minHeight: 15)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColors.burntOrange)
            )
    }

    private func formattedBadgeValue(_ badgeValue: Int) -> String {
        guard badgeValue < 100 else { return "99+" }
        return "\(badgeValue)"
    }

    private func badgeWidth(for text: String) -> CGFloat {
        switch text.count {
        case 1:
            return 15
        case 2:
            return 23
        default:
            return 28
        }
    }
}

#Preview {
    RecipeHeroHeader(
        recipe: RecipeRepository.shared.allRecipes[0],
        isFavorite: true,
        shareText: "Check out this recipe in ALLSPICED.",
        showsBackButton: true,
        onCartTap: {},
        cartBadgeValue: 2,
        onBack: {},
        onFavoriteTap: {}
    )
    .frame(height: 300)
}
