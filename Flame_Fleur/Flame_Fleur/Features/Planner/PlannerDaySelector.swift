import SwiftUI

struct PlannerDaySelector: View {
    let selectedDate: Date
    let visibleMonth: Date
    let weekDates: [Date]
    let mealCountForDate: (Date) -> Int
    let onOpenCalendar: () -> Void
    let onSelectDate: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Button(action: onOpenCalendar) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(visibleMonth.formatted(.dateTime.month(.wide).year()))
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColors.olive)
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

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(weekDates, id: \.self) { date in
                            dayButton(for: date)
                                .id(date)
                        }
                    }
                    .padding(.horizontal, 1)
                    .padding(.vertical, 1)
                }
                .scrollClipDisabled()
                .onChange(of: selectedDate) { _, newDate in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(newDate, anchor: .center)
                    }
                }
            }
        }
    }

    private func dayButton(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let dotCount = min(mealCountForDate(date), 4)

        return Button {
            onSelectDate(date)
        } label: {
            VStack(spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.narrow)))
                    .font(AppTypography.metadata)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.secondaryText)

                Text("\(calendar.component(.day, from: date))")
                    .font(AppTypography.caption)
                    .foregroundStyle(isSelected ? AppColors.elevatedCardBackground : AppColors.primaryText)

                HStack(spacing: 2) {
                    ForEach(0..<dotCount, id: \.self) { _ in
                        Circle()
                            .fill(isSelected ? AppColors.elevatedCardBackground : AppColors.olive.opacity(0.58))
                            .frame(width: 3.2, height: 3.2)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: 38, height: 44)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(isSelected ? AppColors.olive : AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(isSelected ? AppColors.olive : AppColors.warmBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    PlannerDaySelector(
        selectedDate: Date(),
        visibleMonth: Date(),
        weekDates: MealPlannerStore.shared.weekDates,
        mealCountForDate: { date in MealPlannerStore.shared.meals(for: date).count },
        onOpenCalendar: {},
        onSelectDate: { _ in }
    )
    .padding()
    .background(AppColors.appBackground)
}
