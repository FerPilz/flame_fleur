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
                        ForEach(Array(carouselItems.enumerated()), id: \.offset) { index, item in
                            content(item)
                                .frame(width: resolvedWidth)
                                .id(index)
                                .onAppear {
                                    initializeCurrentIndexIfNeeded(at: index)
                                }
                        }
                    }
                    .padding(.vertical, 1)
                    .padding(.horizontal, edgePadding)
                }
                .scrollClipDisabled()
                .onAppear {
                    positionAutoScrollStartIfNeeded(using: scrollProxy)
                }
                .onChange(of: items.map(\.id)) { _, _ in
                    currentIndex = nil
                    didPositionAutoScrollStart = false
                    positionAutoScrollStartIfNeeded(using: scrollProxy)
                }
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
    @State private var didPositionAutoScrollStart = false

    private var usesLoopedAutoScroll: Bool {
        guard let autoScrollInterval else { return false }
        return autoScrollInterval > 0 && items.count > 1
    }

    private var carouselItems: [Item] {
        guard usesLoopedAutoScroll else { return items }
        return items + items + items
    }

    private var initialLoopedIndex: Int {
        items.count
    }

    private var autoScrollTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: autoScrollInterval ?? .greatestFiniteMagnitude, on: .main, in: .common).autoconnect()
    }

    private func initializeCurrentIndexIfNeeded(at index: Int) {
        guard !usesLoopedAutoScroll, currentIndex == nil else { return }
        currentIndex = min(index, max(items.count - 1, 0))
    }

    private func positionAutoScrollStartIfNeeded(using proxy: ScrollViewProxy) {
        guard usesLoopedAutoScroll, !didPositionAutoScrollStart else { return }

        didPositionAutoScrollStart = true
        currentIndex = initialLoopedIndex

        DispatchQueue.main.async {
            proxy.scrollTo(initialLoopedIndex, anchor: .center)
        }
    }

    private func advanceCarousel(using proxy: ScrollViewProxy) {
        guard !carouselItems.isEmpty else { return }

        let nextIndex: Int
        if usesLoopedAutoScroll {
            nextIndex = min((currentIndex ?? initialLoopedIndex) + 1, carouselItems.count - 1)
        } else if let currentIndex {
            nextIndex = (currentIndex + 1) % carouselItems.count
        } else {
            nextIndex = 0
        }

        currentIndex = nextIndex

        withAnimation(.easeInOut(duration: 0.55)) {
            proxy.scrollTo(nextIndex, anchor: .center)
        }

        resetLoopedCarouselIfNeeded(afterScrollingTo: nextIndex, using: proxy)
    }

    private func resetLoopedCarouselIfNeeded(afterScrollingTo index: Int, using proxy: ScrollViewProxy) {
        guard usesLoopedAutoScroll, index >= items.count * 2 else { return }

        let resetIndex = initialLoopedIndex + (index % items.count)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard currentIndex == index else { return }

            currentIndex = resetIndex
            proxy.scrollTo(resetIndex, anchor: .center)
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
