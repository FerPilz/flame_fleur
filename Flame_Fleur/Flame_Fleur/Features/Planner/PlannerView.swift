import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var mealPlannerStore: MealPlannerStore
    @EnvironmentObject private var shoppingCartStore: ShoppingCartStore

    let onExit: () -> Void

    @State private var isCartPresented = false
    @State private var isCalendarPresented = false
    @State private var selectedMealSlot: PlannerSlotSelection?
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
        NavigationStack {
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
                                    mealPlannerStore.selectDate(date)
                                    selectedMealSlot = PlannerSlotSelection(date: date, slot: slot)
                                },
                                onMealTap: { _ in
                                    showToast("Recipe preview coming soon")
                                }
                            )

                            WeeklyMacroBalanceCard(balance: mealPlannerStore.macroBalance)

                            PlannerPremiumInsightsCard(onUpgrade: placeholderUpgrade)

                            SmartSuggestionsCarousel(recipes: smartSuggestionRecipes) { recipe in
                                addSmartSuggestion(recipe)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.xs)
                        .padding(.bottom, AppSpacing.xxxl + AppSpacing.md)
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
            .sheet(item: $selectedMealSlot) { selection in
                MealSelectionView(
                    date: selection.date,
                    slot: selection.slot,
                    recipes: mealSelectionRecipes
                ) { recipe in
                    mealPlannerStore.addRecipe(recipe, on: selection.date, slot: selection.slot)
                    showToast("\(selection.slot.title) added")
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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

                Spacer(minLength: AppSpacing.xs)

                Text("Flame & Fleur")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.olive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: AppSpacing.xs)

                cartButton
            }
            .frame(height: 30)

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

    private var mealSelectionRecipes: [Recipe] {
        recipeRepository.allRecipes
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
        let cartItems = mealPlannerStore.mealsInSelectedWeek.flatMap { meal -> [ShoppingCartItem] in
            guard let recipeID = meal.recipeID,
                  let recipe = recipeRepository.recipe(id: recipeID) else {
                return []
            }

            return recipe.ingredients.map { ingredient in
                ShoppingCartItem(
                    name: ingredient,
                    quantity: 1,
                    unit: "",
                    category: shoppingCategory(for: ingredient),
                    price: estimatedIngredientPrice(for: ingredient),
                    storeName: ShoppingStoreOption.localMarket.displayName,
                    imageName: recipe.imageName,
                    sourceRecipeID: recipe.id,
                    sourceRecipeTitle: recipe.title
                )
            }
        }

        guard !cartItems.isEmpty else {
            showToast("No recipe ingredients to add")
            return
        }

        shoppingCartStore.addItems(cartItems)
        didTapAddPlanToCart = true
        showToast("Plan added to cart (\(cartItems.count) items)")

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

    private func shoppingCategory(for ingredient: String) -> ShoppingCartCategory {
        let value = ingredient.lowercased()

        if value.contains("salmon") || value.contains("chicken") || value.contains("beef") || value.contains("turkey") || value.contains("fish") {
            return .protein
        }

        if value.contains("yogurt") || value.contains("milk") || value.contains("cheese") || value.contains("parmesan") {
            return .dairy
        }

        if value.contains("lemon") || value.contains("tomato") || value.contains("carrot") || value.contains("garlic") || value.contains("herb") || value.contains("ginger") {
            return .produce
        }

        if value.contains("bread") || value.contains("flour") || value.contains("pasta") {
            return .bakery
        }

        if value.contains("stock") || value.contains("oil") || value.contains("lentil") {
            return .pantry
        }

        return .other
    }

    private func estimatedIngredientPrice(for ingredient: String) -> Double {
        switch shoppingCategory(for: ingredient) {
        case .produce:
            return 1.49
        case .dairy:
            return 3.49
        case .protein:
            return 7.99
        case .pantry:
            return 2.49
        case .frozen:
            return 4.49
        case .bakery:
            return 3.29
        case .other:
            return 2.99
        }
    }
}

private struct PlannerSlotSelection: Identifiable {
    let date: Date
    let slot: MealSlot

    var id: String {
        "\(date.timeIntervalSince1970)-\(slot.id)"
    }
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
