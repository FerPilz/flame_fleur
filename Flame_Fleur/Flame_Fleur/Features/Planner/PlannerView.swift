import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore

    let onExit: () -> Void

    @State private var navigationPath: [PlannerRoute] = []
    @State private var isCartPresented = false
    @State private var isCalendarPresented = false
    @State private var isSavePromptPresented = false
    @State private var draftPlanName = ""
    @State private var toastMessage: String?
    @State private var didSavePlan = false
    @State private var didTapAddPlanToCart = false

    private let recipeRepository = RecipeRepository.shared

    init(onExit: @escaping () -> Void = {}) {
        self.onExit = onExit
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                AppColors.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            PlannerWeeklySummaryCard(summary: mealPlannerStore.weeklySummary)

                            PlannerMealGrid(
                                plannerStore: mealPlannerStore,
                                onDayTap: { date in
                                    mealPlannerStore.selectDate(date)
                                },
                                onEmptySlotTap: { date, slot in
                                    openRecipePicker(for: date, slot: slot, mode: .add)
                                },
                                onMealTap: { meal in
                                    openRecipePicker(for: meal.date, slot: meal.slot, mode: .replace)
                                }
                            )

                            WeeklyMacroBalanceCard(balance: mealPlannerStore.selectedDayMacroBalance)

                            PlannerPremiumInsightsCard(onUpgrade: placeholderUpgrade)

                            SmartSuggestionsCarousel(recipes: smartSuggestionRecipes) { recipe in
                                addSmartSuggestion(recipe)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.xs)
                        .padding(.bottom, AppSpacing.xxxl + AppSpacing.xxl + 72)
                    }
                }

                if let toastMessage {
                    plannerToast(toastMessage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .safeAreaInset(edge: .bottom) {
                PlannerBottomActionBar(
                    didAddPlanToCart: didTapAddPlanToCart,
                    didSavePlan: didSavePlan,
                    onAddPlanToCart: addPlanToCart,
                    onSavePlan: presentSavePlanPrompt
                )
            }
            .navigationDestination(isPresented: $isCartPresented) {
                ShoppingCartView {
                    isCartPresented = false
                }
                    .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: PlannerRoute.self) { route in
                switch route {
                case .recipePicker(let context):
                    PlannerRecipePickerView(context: context) { recipeID in
                        navigationPath.append(.recipe(recipeID: recipeID, context: context))
                    }
                case .recipe(let recipeID, let context):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeDetailView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            },
                            onViewIngredients: {
                                navigationPath.append(.ingredients(recipeID))
                            },
                            plannerSelectionContext: context,
                            onAddToPlanner: { recipe in
                                let didAdd = mealPlannerStore.addRecipeToPlannerSlot(
                                    recipeID: recipe.id,
                                    date: context.date,
                                    mealType: context.mealType,
                                    slotID: context.slotID,
                                    mode: context.mode
                                )

                                if didAdd {
                                    navigationPath.removeAll()
                                    showToast(context.mode == .add ? "Added to \(context.mealType.title)" : "Replaced in \(context.mealType.title)")
                                } else {
                                    showToast("Recipe is unavailable")
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                case .ingredients(let recipeID):
                    if recipeRepository.recipe(id: recipeID) != nil {
                        RecipeIngredientsView(
                            recipeID: recipeID,
                            onBack: {
                                if !navigationPath.isEmpty {
                                    navigationPath.removeLast()
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $isCalendarPresented) {
                PlannerCalendarPickerSheet(
                    selectedDate: Binding(
                        get: { mealPlannerStore.selectedDate },
                        set: { mealPlannerStore.selectDate($0) }
                    )
                )
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(AppRadius.hero)
            }
            .alert("Save Plan", isPresented: $isSavePromptPresented) {
                TextField("Plan name", text: $draftPlanName)
                Button("Cancel", role: .cancel) {
                    draftPlanName = ""
                }
                Button("Save") {
                    saveNamedPlan()
                }
            } message: {
                Text("Name this week's meal plan.")
            }
            .tint(AppColors.olive)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            ZStack {
                Text("Flame & Fleur")
                    .font(AppTypography.brandTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .padding(.horizontal, AppTopActionMetrics.centeredTitleInset)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: AppSpacing.sm) {
                    IconCircleButton(
                        systemName: "chevron.left",
                        accessibilityLabel: "Exit meal planner",
                        size: AppTopActionMetrics.buttonSize,
                        backgroundColor: AppColors.elevatedCardBackground,
                        foregroundColor: AppColors.darkOlive,
                        action: onExit
                    )
                    .frame(width: AppTopActionMetrics.actionGroupWidth, alignment: .leading)

                    Spacer(minLength: 0)

                    cartButton
                }
            }
            .frame(height: 44)

            Text("Meal Planner")
                .font(AppTypography.heroTitle)
                .foregroundStyle(AppColors.olive)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)

            PlannerDaySelector(
                selectedDate: mealPlannerStore.selectedDate,
                visibleMonth: mealPlannerStore.visibleMonth,
                weekDates: mealPlannerStore.weekDates,
                mealCountForDate: { date in
                    mealPlannerStore.meals(for: date).count
                },
                onOpenCalendar: { isCalendarPresented = true },
                onSelectDate: { date in
                    mealPlannerStore.selectDate(date)
                }
            )
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.xs)
        .padding(.bottom, AppSpacing.xxs)
        .background(AppColors.appBackground)
    }

    private var cartButton: some View {
        IconCircleButton(
            systemName: "cart",
            accessibilityLabel: "Open shopping cart",
            size: AppTopActionMetrics.buttonSize,
            backgroundColor: AppColors.elevatedCardBackground,
            foregroundColor: AppColors.darkOlive,
            action: { isCartPresented = true }
        )
        .frame(width: AppTopActionMetrics.actionGroupWidth, alignment: .trailing)
    }

    private func openRecipePicker(for date: Date, slot: MealSlot, mode: PlannerRecipeSelectionContext.Mode) {
        mealPlannerStore.selectDate(date)

        navigationPath.append(
            .recipePicker(
                PlannerRecipeSelectionContext(
                    date: mealPlannerStore.selectedDate,
                    dayLabel: dayLabel(for: date),
                    mealType: slot,
                    slotID: slot.id,
                    mode: mode
                )
            )
        )
    }

    private var smartSuggestionRecipes: [Recipe] {
        var seenIDs = Set<String>()
        let recipes = recipeRepository.aiRecommendedRecipes
            + recipeRepository.topPicksRecipes
            + recipeRepository.allRecipes

        return Array(
            recipes.filter { recipe in
                seenIDs.insert(recipe.id).inserted
            }
            .prefix(8)
        )
    }

    private func placeholderUpgrade() {
        showToast("Premium insights coming soon")
    }

    private func addSmartSuggestion(_ recipe: Recipe) {
        let didAdd = mealPlannerStore.addRecipeToFirstAvailableWeekSlot(
            recipe,
            preferredDate: mealPlannerStore.selectedDate
        )

        showToast(didAdd ? "Added to plan" : "No empty slots this week")
    }

    private func addPlanToCart() {
        var addedItemCount = 0

        for meal in mealPlannerStore.mealsInSelectedWeek {
            guard let recipeID = meal.recipeID,
                  let recipe = recipeRepository.recipe(id: recipeID) else {
                continue
            }

            shoppingCartStore.addRecipeIngredients(recipe.structuredIngredients, from: recipe)
            addedItemCount += recipe.structuredIngredients.count
        }

        guard addedItemCount > 0 else {
            showToast("No recipe ingredients to add")
            return
        }

        didTapAddPlanToCart = true
        showToast("Plan added to cart (\(addedItemCount) items)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            didTapAddPlanToCart = false
        }
    }

    private func presentSavePlanPrompt() {
        draftPlanName = "Week of \(mealPlannerStore.weekDates.first?.formatted(.dateTime.month(.abbreviated).day()) ?? "Meal Plan")"
        isSavePromptPresented = true
    }

    private func saveNamedPlan() {
        let trimmedName = draftPlanName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showToast("Enter a plan name")
            return
        }

        mealPlannerStore.savePlan(named: trimmedName)
        draftPlanName = ""
        didSavePlan = true
        showToast("Plan saved")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            didSavePlan = false
        }
    }

    private func plannerToast(_ message: String) -> some View {
        Text(message)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColors.elevatedCardBackground)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 34)
            .background(Capsule(style: .continuous).fill(AppColors.darkOlive))
            .padding(.bottom, AppSpacing.xxxl + AppSpacing.md)
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if toastMessage == message {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toastMessage = nil
                }
            }
        }
    }

    private func dayLabel(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }

}

private enum PlannerRoute: Hashable {
    case recipePicker(PlannerRecipeSelectionContext)
    case recipe(recipeID: String, context: PlannerRecipeSelectionContext)
    case ingredients(String)
}

private struct PlannerMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Planner Menu")
                            .font(AppTypography.heroTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Planner shortcuts are local placeholders in this build.")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    IconCircleButton(
                        systemName: "xmark",
                        accessibilityLabel: "Close planner menu",
                        size: 30,
                        action: { dismiss() }
                    )
                }

                VStack(spacing: AppSpacing.xs) {
                    menuRow(systemImage: "calendar", title: "This Week", detail: "Current planning week")
                    menuRow(systemImage: "tray.full", title: "Saved Plans", detail: "Local plan names")
                    menuRow(systemImage: "slider.horizontal.3", title: "Planner Preferences", detail: "Coming later")
                }

                Spacer(minLength: AppSpacing.md)

                PrimaryButton("Done", style: .olive, height: 44) {
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            .background(AppColors.appBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func menuRow(systemImage: String, title: String, detail: String) -> some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm
        ) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.olive)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(AppColors.softOlive))

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(title)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text(detail)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(MealPlannerStore.shared)
        .environmentObject(ShoppingCartStore(items: SampleShoppingCartItems.currentWeek))
}
