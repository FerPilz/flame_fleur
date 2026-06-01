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
        HStack(spacing: 0) {
            ForEach(options) { option in
                Button {
                    selection = option.id
                    onSelect(option)
                } label: {
                    segmentContent(option)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, AppSpacing.xs)
        .padding(.bottom, AppSpacing.xs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.divider.opacity(0.75))
                .frame(height: 1)
        }
    }

    private func segmentContent(_ option: TopSegmentOption) -> some View {
        let isActive = selection == option.id

        return VStack(spacing: AppSpacing.xxs) {
            Image(systemName: option.systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isActive ? AppColors.olive : AppColors.tertiaryText)
                .frame(height: 15)

            Text(option.title)
                .font(AppTypography.tabLabel)
                .foregroundStyle(isActive ? AppColors.olive : AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .allowsTightening(true)

            Capsule(style: .continuous)
                .fill(isActive ? AppColors.olive : .clear)
                .frame(width: 28, height: 2)
        }
        .contentShape(Rectangle())
    }
}

private struct TopSegmentSelectorPreview: View {
    @State private var selection = "featured"

    var body: some View {
        TopSegmentSelector(
            options: [
                TopSegmentOption(id: "featured", title: "Featured", systemImage: "leaf.fill"),
                TopSegmentOption(id: "community", title: "Community", systemImage: "person.2.fill"),
                TopSegmentOption(id: "topPicks", title: "Top Picks", systemImage: "star.fill"),
                TopSegmentOption(id: "ai", title: "AI Recommend", systemImage: "sparkles")
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
