import SwiftUI

struct TopSegmentOption: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String

    init(id: String, title: String, systemImage: String) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

struct TopSegmentSelector: View {
    let options: [TopSegmentOption]
    @Binding var selection: String
    let onSelect: (TopSegmentOption) -> Void

    init(
        options: [TopSegmentOption],
        selection: Binding<String>,
        onSelect: @escaping (TopSegmentOption) -> Void = { _ in }
    ) {
        self.options = options
        self._selection = selection
        self.onSelect = onSelect
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppSpacing.md) {
                    ForEach(options) { option in
                        Button {
                            selection = option.id
                            onSelect(option)
                        } label: {
                            segmentContent(option)
                        }
                        .buttonStyle(.plain)
                        .id(scrollID(for: option.id))
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: AppSpacing.xl + AppSpacing.xxs)
            .onAppear {
                scrollToSelection(selection, proxy: proxy, animated: false)
            }
            .onChange(of: selection) { _, newSelection in
                scrollToSelection(newSelection, proxy: proxy)
            }
        }
    }

    private func segmentContent(_ option: TopSegmentOption) -> some View {
        let isActive = selection == option.id

        return VStack(spacing: 3) {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 16, weight: .semibold))

                Text(option.title)
                    .font(AppTypography.metadata)
            }
            .foregroundStyle(isActive ? AppColors.deepBasil : AppColors.secondaryText)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)

            Capsule(style: .continuous)
                .fill(isActive ? AppColors.deepBasil : .clear)
                .frame(height: 2)
        }
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func scrollToSelection(_ selection: String, proxy: ScrollViewProxy, animated: Bool = true) {
        guard options.contains(where: { $0.id == selection }) else { return }

        let scrollAction = {
            proxy.scrollTo(scrollID(for: selection), anchor: .center)
        }

        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scrollAction()
                }
            } else {
                scrollAction()
            }
        }
    }

    private func scrollID(for selection: String) -> String {
        "top-segment-\(selection)"
    }
}

private struct TopSegmentSelectorPreview: View {
    @State private var selection = "featured"

    var body: some View {
        TopSegmentSelector(
            options: [
                TopSegmentOption(id: "featured", title: "Featured", systemImage: "leaf.fill"),
                TopSegmentOption(id: "beef", title: "Beef", systemImage: "fork.knife"),
                TopSegmentOption(id: "vegetarian", title: "Vegetarian", systemImage: "leaf.fill"),
                TopSegmentOption(id: "chickenSalad", title: "Chicken Salad", systemImage: "leaf.circle.fill"),
                TopSegmentOption(id: "tuna", title: "Tuna", systemImage: "fish.fill"),
                TopSegmentOption(id: "plantBasedBowls", title: "Plant Based Bowls", systemImage: "takeoutbag.and.cup.and.straw.fill"),
                TopSegmentOption(id: "piesAndTarts", title: "Pies & Tarts", systemImage: "birthday.cake.fill"),
                TopSegmentOption(id: "mexican", title: "Mexican", systemImage: "taco.fill"),
                TopSegmentOption(id: "korean", title: "Korean", systemImage: "bowl.fill"),
                TopSegmentOption(id: "breakfastBakes", title: "Breakfast Bakes", systemImage: "croissant.fill"),
                TopSegmentOption(id: "cookies", title: "Cookies", systemImage: "cookie.fill"),
                TopSegmentOption(id: "highProtein", title: "High Protein", systemImage: "dumbbell.fill")
            ],
            selection: $selection
        )
        .padding()
        .background(AppColors.appBackground)
    }
}

#Preview {
    TopSegmentSelectorPreview()
}
