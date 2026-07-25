import SwiftUI

struct PlannerDaySelector: View {
    let selectedDate: Date
    let visibleMonth: Date
    let rangeStartDate: Date?
    let rangeEndDate: Date?
    let mealCountForDate: (Date) -> Int
    let onOpenCalendar: () -> Void
    let onSelectDate: (Date) -> Void

    private let calendar = Calendar.current
    @State private var didScrollToInitialDate = false

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Button(action: onOpenCalendar) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(visibleMonth.formatted(.dateTime.month(.wide).year()))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.deepBasil)
                        .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 26)
                .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground))
                .overlay(Capsule(style: .continuous).stroke(AppColors.warmBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Open calendar"))

            GeometryReader { geometry in
                let dayWidth = PlannerDateCarouselMetrics.dayWidth(for: geometry.size.width)

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: PlannerDateCarouselMetrics.itemSpacing) {
                            ForEach(carouselDates, id: \.self) { date in
                                dayButton(for: date, width: dayWidth, scrollProxy: proxy)
                                    .id(normalizedDate(date))
                            }
                        }
                        .padding(.vertical, 1)
                    }
                    .scrollClipDisabled()
                    .onAppear {
                        guard !didScrollToInitialDate else { return }
                        didScrollToInitialDate = true
                        proxy.scrollTo(normalizedDate(selectedDate), anchor: .leading)
                    }
                }
            }
            .frame(height: PlannerDateCarouselMetrics.itemHeight + 2)
        }
    }

    private var carouselDates: [Date] {
        PlannerDateCarouselMetrics.dates(ensuring: selectedDate, calendar: calendar)
    }

    private func dayButton(for date: Date, width: CGFloat, scrollProxy: ScrollViewProxy) -> some View {
        let normalizedDate = normalizedDate(date)
        let isSelected = calendar.isDate(normalizedDate, inSameDayAs: selectedDate)
        let isInRange = isDateInSelectedRange(normalizedDate)
        let isRangeStart = isDateRangeStart(normalizedDate)
        let isRangeEnd = isDateRangeEnd(normalizedDate)
        let isToday = calendar.isDateInToday(normalizedDate)
        let dotCount = min(mealCountForDate(date), 4)

        return Button {
            onSelectDate(normalizedDate)

            withAnimation(.easeInOut(duration: 0.24)) {
                scrollProxy.scrollTo(normalizedDate, anchor: .leading)
            }
        } label: {
            VStack(spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(AppTypography.metadata)
                    .foregroundStyle(foregroundColor(isSelected: isSelected, isInRange: isInRange, isBoundary: isRangeStart || isRangeEnd, isPrimaryText: false))

                Text("\(calendar.component(.day, from: date))")
                    .font(AppTypography.caption)
                    .foregroundStyle(foregroundColor(isSelected: isSelected, isInRange: isInRange, isBoundary: isRangeStart || isRangeEnd, isPrimaryText: true))

                HStack(spacing: 2) {
                    ForEach(0..<dotCount, id: \.self) { _ in
                        Circle()
                            .fill(isSelected ? AppColors.elevatedCardBackground : AppColors.olive.opacity(isInRange ? 0.72 : 0.58))
                            .frame(width: 3.2, height: 3.2)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: width, height: PlannerDateCarouselMetrics.itemHeight)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(backgroundColor(isSelected: isSelected, isInRange: isInRange, isBoundary: isRangeStart || isRangeEnd))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(
                        borderColor(isSelected: isSelected, isInRange: isInRange, isBoundary: isRangeStart || isRangeEnd, isToday: isToday),
                        lineWidth: borderWidth(isSelected: isSelected, isInRange: isInRange, isBoundary: isRangeStart || isRangeEnd, isToday: isToday)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func normalizedDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func isDateInSelectedRange(_ date: Date) -> Bool {
        guard let rangeStartDate else {
            return false
        }

        let start = normalizedDate(rangeStartDate)
        let end = normalizedDate(rangeEndDate ?? rangeStartDate)
        let lowerBound = min(start, end)
        let upperBound = max(start, end)

        return date >= lowerBound && date <= upperBound
    }

    private func isDateRangeStart(_ date: Date) -> Bool {
        guard let rangeStartDate else {
            return false
        }

        return calendar.isDate(date, inSameDayAs: rangeStartDate)
    }

    private func isDateRangeEnd(_ date: Date) -> Bool {
        guard let rangeEndDate else {
            return false
        }

        return calendar.isDate(date, inSameDayAs: rangeEndDate)
    }

    private func foregroundColor(isSelected: Bool, isInRange: Bool, isBoundary: Bool, isPrimaryText: Bool) -> Color {
        if isSelected {
            return AppColors.elevatedCardBackground
        }

        if isBoundary {
            return isPrimaryText ? AppColors.darkOlive : AppColors.deepBasil
        }

        if isInRange {
            return isPrimaryText ? AppColors.darkOlive : AppColors.deepBasil
        }

        return isPrimaryText ? AppColors.primaryText : AppColors.secondaryText
    }

    private func backgroundColor(isSelected: Bool, isInRange: Bool, isBoundary: Bool) -> Color {
        if isSelected {
            return AppColors.deepBasil
        }

        if isBoundary {
            return AppColors.basilGreen.opacity(0.22)
        }

        if isInRange {
            return AppColors.softOlive
        }

        return AppColors.elevatedCardBackground
    }

    private func borderColor(isSelected: Bool, isInRange: Bool, isBoundary: Bool, isToday: Bool) -> Color {
        if isSelected {
            return AppColors.deepBasil
        }

        if isBoundary || isInRange || isToday {
            return AppColors.basilGreen
        }

        return AppColors.warmBorder
    }

    private func borderWidth(isSelected: Bool, isInRange: Bool, isBoundary: Bool, isToday: Bool) -> CGFloat {
        if isSelected {
            return 2.4
        }

        if isBoundary {
            return 2.2
        }

        if isInRange {
            return 1.6
        }

        return isToday ? 1.5 : 1
    }
}

private enum PlannerDateCarouselMetrics {
    static let daysBeforeToday = 30
    static let daysAfterToday = 90
    static let maximumVisibleDayCount = 7
    static let itemHeight: CGFloat = 58
    static let itemSpacing = AppSpacing.sm

    static func dates(ensuring selectedDate: Date, calendar: Calendar) -> [Date] {
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        let rangeStart = calendar.date(byAdding: .day, value: -daysBeforeToday, to: today) ?? today
        let rangeEnd = calendar.date(byAdding: .day, value: daysAfterToday, to: today) ?? today
        let startDate = min(rangeStart, selectedDay)
        let endDate = max(rangeEnd, selectedDay)
        let dayCount = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        return (0...max(dayCount, 0)).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startDate).map {
                calendar.startOfDay(for: $0)
            }
        }
    }

    static func dayWidth(for availableWidth: CGFloat) -> CGFloat {
        let totalSpacing = itemSpacing * CGFloat(maximumVisibleDayCount - 1)
        let proposedWidth = (availableWidth - totalSpacing) / CGFloat(maximumVisibleDayCount)
        return max(40, ceil(proposedWidth))
    }
}

#Preview {
    PlannerDaySelector(
        selectedDate: Date(),
        visibleMonth: Date(),
        rangeStartDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
        rangeEndDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        mealCountForDate: { date in MealPlannerStore.shared.meals(for: date).count },
        onOpenCalendar: {},
        onSelectDate: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
