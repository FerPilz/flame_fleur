import SwiftUI

struct HorizontalCarousel<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let visibleItemCount: CGFloat
    let itemSpacing: CGFloat
    let cardWidth: CGFloat?
    let cardHeight: CGFloat
    let content: (Item) -> Content

    init(
        items: [Item],
        visibleItemCount: CGFloat = 3,
        itemSpacing: CGFloat = AppSpacing.carouselItemSpacing,
        cardWidth: CGFloat? = nil,
        cardHeight: CGFloat = 150,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.visibleItemCount = visibleItemCount
        self.itemSpacing = itemSpacing
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let resolvedWidth = cardWidth ?? defaultCardWidth(containerWidth: proxy.size.width)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: itemSpacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: resolvedWidth)
                    }
                }
                .padding(.vertical, 1)
                .padding(.horizontal, 1)
            }
            .scrollClipDisabled()
        }
        .frame(height: cardHeight)
    }

    private func defaultCardWidth(containerWidth: CGFloat) -> CGFloat {
        let totalSpacing = itemSpacing * max(visibleItemCount - 1, 0)
        return floor((containerWidth - totalSpacing) / visibleItemCount)
    }
}

#Preview {
    HorizontalCarousel(
        items: [
            PreviewRecipe(title: "Pesto Primavera"),
            PreviewRecipe(title: "Hearty Lentil Soup"),
            PreviewRecipe(title: "Fudgy Brownie")
        ]
    ) { recipe in
        SurfaceCard(contentPadding: AppSpacing.sm) {
            Text(recipe.title)
                .font(AppTypography.cardTitle)
        }
    }
    .padding()
    .background(AppColors.appBackground)
}

private struct PreviewRecipe: Identifiable {
    let id = UUID()
    let title: String
}
