import SwiftUI

struct TopSegmentOption: Identifiable, Hashable {
    let id: String
    let title: String
    let iconAssetName: String

    init(id: String, title: String, iconAssetName: String) {
        self.id = id
        self.title = title
        self.iconAssetName = iconAssetName
    }
}

struct TopSegmentSelector: View {
    let options: [TopSegmentOption]
    @Binding var selection: String
    let allowsDeselection: Bool
    let onSelect: (TopSegmentOption) -> Void

    init(
        options: [TopSegmentOption],
        selection: Binding<String>,
        allowsDeselection: Bool = false,
        onSelect: @escaping (TopSegmentOption) -> Void = { _ in }
    ) {
        self.options = options
        self._selection = selection
        self.allowsDeselection = allowsDeselection
        self.onSelect = onSelect
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppSpacing.md) {
                    ForEach(options) { option in
                        Button {
                            selection = allowsDeselection && selection == option.id ? "" : option.id
                            onSelect(option)
                        } label: {
                            segmentContent(option)
                        }
                        .buttonStyle(.plain)
                        .id(option.id)
                    }
                }
                .padding(.vertical, 3)
            }
            .frame(height: TopSegmentSelectorMetrics.height)
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
                Image(option.iconAssetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)

                Text(option.title)
                    .font(.system(size: TopSegmentSelectorMetrics.titleFontSize, weight: isActive ? .semibold : .medium))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
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
            proxy.scrollTo(selection, anchor: .center)
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

}

private enum TopSegmentSelectorMetrics {
    static let titleFontSize: CGFloat = 16.5
    static let height: CGFloat = 40
}

private struct TopSegmentSelectorPreview: View {
    @State private var selection = "featured"

    var body: some View {
        TopSegmentSelector(
            options: [
                TopSegmentOption(id: "featured", title: "Featured", iconAssetName: "icon_featured"),
                TopSegmentOption(id: "beef", title: "Beef", iconAssetName: "icon_beef"),
                TopSegmentOption(id: "vegetarian", title: "Vegetarian", iconAssetName: "icon_vegetarian"),
                TopSegmentOption(id: "chickenSalad", title: "Chicken Salad", iconAssetName: "icon_chicken_salad"),
                TopSegmentOption(id: "tuna", title: "Tuna", iconAssetName: "icon_tuna"),
                TopSegmentOption(id: "plantBasedBowls", title: "Plant Based Bowls", iconAssetName: "icon_plant_based_bowls"),
                TopSegmentOption(id: "piesAndTarts", title: "Pies & Tarts", iconAssetName: "icon_pies_tarts"),
                TopSegmentOption(id: "mexican", title: "Mexican", iconAssetName: "icon_mexican"),
                TopSegmentOption(id: "korean", title: "Korean", iconAssetName: "icon_korean"),
                TopSegmentOption(id: "breakfastBakes", title: "Breakfast Bakes", iconAssetName: "icon_breakfast_bakes"),
                TopSegmentOption(id: "cookies", title: "Cookies", iconAssetName: "icon_cookies"),
                TopSegmentOption(id: "highProtein", title: "High Protein", iconAssetName: "icon_high_protein")
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
