import SwiftUI

struct PlannerCalendarPickerSheet: View {
    @Binding private var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var draftDate: Date

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xxs), count: 7)

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _draftDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                header
                calendarCard

                PrimaryButton("Done", style: .olive, height: 42) {
                    selectedDate = calendar.startOfDay(for: draftDate)
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.sm)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            IconCircleButton(
                systemName: "chevron.left",
                accessibilityLabel: "Close calendar",
                size: AppTopActionMetrics.buttonSize,
                action: { dismiss() }
            )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Choose a Planning Day")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(draftDate.formatted(.dateTime.month(.wide).day().year()))
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()
        }
        .frame(minHeight: 42)
    }

    private var calendarCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    IconCircleButton(
                        systemName: "chevron.left",
                        accessibilityLabel: "Previous month",
                        size: AppTopActionMetrics.compactButtonSize,
                        action: { moveDraftMonth(by: -1) }
                    )

                    Text(monthTitle)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.basilGreen)
                        .frame(maxWidth: .infinity, alignment: .center)

                    IconCircleButton(
                        systemName: "chevron.right",
                        accessibilityLabel: "Next month",
                        size: AppTopActionMetrics.compactButtonSize,
                        action: { moveDraftMonth(by: 1) }
                    )
                }

                LazyVGrid(columns: columns, spacing: AppSpacing.xxs) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                            .frame(height: 18)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(calendarDays) { day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: PlannerCalendarDay) -> some View {
        Group {
            if let date = day.date {
                let isSelected = calendar.isDate(date, inSameDayAs: draftDate)

                Button {
                    draftDate = calendar.startOfDay(for: date)
                    selectedDate = draftDate
                } label: {
                    Text("\(calendar.component(.day, from: date))")
                        .font(AppTypography.caption)
                        .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.primaryText)
                        .frame(height: 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            Circle()
                                .fill(isSelected ? AppColors.basilGreen : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(isSelected ? AppColors.basilGreen : AppColors.warmBorder.opacity(0.52), lineWidth: isSelected ? 1 : 0)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            } else {
                Color.clear
                    .frame(height: 32)
            }
        }
    }

    private var monthTitle: String {
        monthStart.formatted(.dateTime.month(.wide).year())
    }

    private var monthStart: Date {
        let components = calendar.dateComponents([.year, .month], from: draftDate)
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: draftDate)
    }

    private var calendarDays: [PlannerCalendarDay] {
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlankCount = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days = (0..<leadingBlankCount).map { PlannerCalendarDay(id: "blank-\($0)", date: nil) }

        days.append(
            contentsOf: dayRange.compactMap { day -> PlannerCalendarDay? in
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else {
                    return nil
                }

                return PlannerCalendarDay(id: "day-\(day)", date: calendar.startOfDay(for: date))
            }
        )

        return days
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = max(calendar.firstWeekday - 1, 0)

        return Array(symbols[startIndex...]) + Array(symbols[..<startIndex])
    }

    private func moveDraftMonth(by value: Int) {
        guard let newDate = calendar.date(byAdding: .month, value: value, to: monthStart) else {
            return
        }

        draftDate = calendar.startOfDay(for: newDate)
    }
}

private struct PlannerCalendarDay: Identifiable {
    let id: String
    let date: Date?
}

#Preview {
    PlannerCalendarPickerSheet(selectedDate: .constant(Date()))
}
