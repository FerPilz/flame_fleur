import SwiftUI

struct RecipeIngredientsOverlayPanel: View {
    let recipe: Recipe
    @Binding var isPresented: Bool

    @EnvironmentObject private var cartStore: ShoppingCartStore
    @State private var servings: Int
    @State private var selectedIngredientIndexes: Set<Int>
    @State private var addSelectedMessage: String?

    init(recipe: Recipe, isPresented: Binding<Bool>) {
        self.recipe = recipe
        self._isPresented = isPresented
        _servings = State(initialValue: max(recipe.servings, 1))
        _selectedIngredientIndexes = State(initialValue: Set(recipe.structuredIngredients.indices))
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule(style: .continuous)
                .fill(AppColors.warmBorder)
                .frame(width: 44, height: 5)
                .padding(.top, AppSpacing.sm)

            header
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.sm)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    servingsControl
                    checklistHeader
                    checklist
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }

            bottomActionBar
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: AppRadius.hero,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: AppRadius.hero,
                style: .continuous
            )
            .fill(AppColors.appBackground)
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: 0, y: -AppShadow.cardYOffset)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Ingredients")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(recipe.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.sm)

            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.olive)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppColors.elevatedCardBackground)
                    )
                    .overlay(
                        Circle()
                            .stroke(AppColors.warmBorder.opacity(0.78), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close ingredients")
        }
    }

    private var servingsControl: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            HStack(spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Servings")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    Text("Adjusts this checklist locally")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer(minLength: AppSpacing.sm)

                stepperButton(systemName: "minus") {
                    servings = max(1, servings - 1)
                }

                Text("\(servings)")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: AppSpacing.xl)

                stepperButton(systemName: "plus") {
                    servings += 1
                }
            }
        }
    }

    private var checklistHeader: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                toggleSelectAll()
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
                    Text("Select all")
                }
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.olive)
            }
            .buttonStyle(.plain)

            Spacer(minLength: AppSpacing.sm)

            Text("\(selectedIngredientIndexes.count) selected")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    private var checklist: some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(Array(recipe.structuredIngredients.enumerated()), id: \.offset) { index, ingredient in
                IngredientChecklistRow(
                    ingredient: ingredient,
                    isSelected: selectedIngredientIndexes.contains(index)
                ) {
                    toggleIngredient(at: index)
                }
            }
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: AppSpacing.xs) {
            if let addSelectedMessage {
                Text(addSelectedMessage)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                    .transition(.opacity)
            }

            PrimaryButton("Add Selected to Cart", systemImage: "cart.badge.plus", style: .recipe, height: 50) {
                let selectedIngredients = recipe.structuredIngredients.enumerated().compactMap { index, ingredient in
                    selectedIngredientIndexes.contains(index) ? ingredient : nil
                }

                guard !selectedIngredients.isEmpty else {
                    withAnimation(.easeInOut) {
                        addSelectedMessage = "Select ingredients to add."
                    }
                    return
                }

                cartStore.addRecipeIngredients(selectedIngredients, from: recipe)

                withAnimation(.easeInOut) {
                    addSelectedMessage = "\(selectedIngredients.count) ingredients added to the cart."
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [
                    AppColors.appBackground.opacity(0.28),
                    AppColors.appBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var isAllSelected: Bool {
        selectedIngredientIndexes.count == recipe.structuredIngredients.count
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(AppColors.cardBackground)
                .frame(width: AppSpacing.xxl, height: AppSpacing.xxl)
                .overlay(
                    Image(systemName: systemName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.olive)
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func toggleIngredient(at index: Int) {
        if selectedIngredientIndexes.contains(index) {
            selectedIngredientIndexes.remove(index)
        } else {
            selectedIngredientIndexes.insert(index)
        }
    }

    private func toggleSelectAll() {
        if isAllSelected {
            selectedIngredientIndexes.removeAll()
        } else {
            selectedIngredientIndexes = Set(recipe.structuredIngredients.indices)
        }
    }
}

#Preview {
    RecipeIngredientsOverlayPanel(
        recipe: RecipeRepository.shared.allRecipes[0],
        isPresented: .constant(true)
    )
    .environmentObject(ShoppingCartStore.shared)
}
