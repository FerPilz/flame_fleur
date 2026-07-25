import Combine
import SwiftUI

struct HorizontalCarousel<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let visibleItemCount: CGFloat
    let itemSpacing: CGFloat
    let cardWidth: CGFloat?
    let cardHeight: CGFloat
    let edgePadding: CGFloat
    let autoScrollInterval: TimeInterval?
    let content: (Item) -> Content

    init(
        items: [Item],
        visibleItemCount: CGFloat = 3,
        itemSpacing: CGFloat = AppSpacing.carouselItemSpacing,
        cardWidth: CGFloat? = nil,
        cardHeight: CGFloat = 150,
        edgePadding: CGFloat = 1,
        autoScrollInterval: TimeInterval? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.visibleItemCount = visibleItemCount
        self.itemSpacing = itemSpacing
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.edgePadding = edgePadding
        self.autoScrollInterval = autoScrollInterval
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let resolvedWidth = cardWidth ?? defaultCardWidth(containerWidth: proxy.size.width)

            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: itemSpacing) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            content(item)
                                .frame(width: resolvedWidth)
                                .id(item.id)
                                .onAppear {
                                    if currentIndex == nil {
                                        currentIndex = min(index, max(items.count - 1, 0))
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 1)
                    .padding(.horizontal, edgePadding)
                }
                .scrollClipDisabled()
                .onReceive(autoScrollTimer) { _ in
                    guard let autoScrollInterval, items.count > 1 else { return }
                    guard autoScrollInterval > 0 else { return }
                    advanceCarousel(using: scrollProxy)
                }
            }
        }
        .frame(height: cardHeight)
    }

    @State private var currentIndex: Int?

    private var autoScrollTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: autoScrollInterval ?? .greatestFiniteMagnitude, on: .main, in: .common).autoconnect()
    }

    private func advanceCarousel(using proxy: ScrollViewProxy) {
        guard !items.isEmpty else { return }

        let nextIndex: Int
        if let currentIndex {
            nextIndex = (currentIndex + 1) % items.count
        } else {
            nextIndex = 0
        }

        currentIndex = nextIndex

        withAnimation(.easeInOut(duration: 0.55)) {
            proxy.scrollTo(items[nextIndex].id, anchor: .center)
        }
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
