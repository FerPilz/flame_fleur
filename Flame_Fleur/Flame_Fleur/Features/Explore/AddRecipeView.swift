import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userRecipeStore: UserRecipeStore

    @State private var titleText = ""
    @State private var subcategoryText = ""
    @State private var servings = 2
    @State private var ingredientRows: [IngredientDraft] = [IngredientDraft()]
    @State private var instructionSteps: [String] = [""]
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    #if canImport(UIKit)
    @State private var selectedPhotoImage: UIImage?
    #endif
    @State private var validationMessage: String?

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    header
                    imagePickerCard
                    detailsCard
                    ingredientsCard
                    instructionsCard
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.xxxl + AppSpacing.xxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            saveBar
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else { return }
            loadPhoto(from: newValue)
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back",
                    size: AppTopActionMetrics.buttonSize,
                    action: { dismiss() }
                )
                .frame(width: 44, alignment: .leading)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }

            Text("Add Recipe")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(height: 50)
    }

    private var imagePickerCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.hero,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Recipe image")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColors.primaryText)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack(alignment: .bottomLeading) {
                        imagePreview

                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "photo")
                                .font(AppTypography.metadata)

                            Text(selectedPhotoData == nil ? "Choose a photo" : "Change photo")
                                .font(AppTypography.metadata)
                        }
                        .foregroundStyle(AppColors.olive)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xxs)
                        .background(Capsule(style: .continuous).fill(AppColors.elevatedCardBackground.opacity(0.92)))
                        .padding(AppSpacing.sm)
                    }
                    .frame(height: 190)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if selectedPhotoData != nil {
                    Button {
                        selectedPhotoData = nil
                        selectedPhotoItem = nil
                        #if canImport(UIKit)
                        selectedPhotoImage = nil
                        #endif
                    } label: {
                        Text("Remove image")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var imagePreview: some View {
        Group {
            #if canImport(UIKit)
            if let selectedPhotoImage {
                Image(uiImage: selectedPhotoImage)
                    .resizable()
                    .scaledToFill()
            } else {
                fallbackImagePreview
            }
            #else
            fallbackImagePreview
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppColors.warmBorder, lineWidth: 1)
        )
    }

    private var fallbackImagePreview: some View {
        ZStack {
            FoodImagePlaceholder(kind: .bowl, style: .hero)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: AppSpacing.xxs) {
                Image(systemName: "book.closed")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppColors.elevatedCardBackground)

                Text("Optional")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.elevatedCardBackground)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(Capsule(style: .continuous).fill(AppColors.darkOlive.opacity(0.84)))
        }
    }

    private var detailsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                labeledField(title: "Recipe name", placeholder: "Spicy Tomato Pasta", text: $titleText)

                Divider()
                    .overlay(AppColors.warmBorder)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Servings")
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColors.primaryText)

                    HStack {
                        stepperButton(systemName: "minus") {
                            servings = max(1, servings - 1)
                        }

                        Text("\(servings)")
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColors.primaryText)
                            .frame(minWidth: 30)

                        stepperButton(systemName: "plus") {
                            servings += 1
                        }

                        Spacer(minLength: 0)
                    }
                }

                Divider()
                    .overlay(AppColors.warmBorder)

                labeledField(title: "Subcategory", placeholder: "My Recipes", text: $subcategoryText)
            }
        }
    }

    private var ingredientsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                sectionHeader(title: "Ingredients", actionTitle: "Add Ingredient") {
                    addIngredientRow()
                }

                VStack(spacing: AppSpacing.sm) {
                    ForEach(ingredientIndices, id: \.self) { index in
                        ingredientRow(at: index)
                    }
                }
            }
        }
    }

    private var instructionsCard: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.sm,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                sectionHeader(title: "Instructions", actionTitle: "Add Step") {
                    addInstructionStep()
                }

                VStack(spacing: AppSpacing.sm) {
                    ForEach(instructionIndices, id: \.self) { index in
                        instructionRow(at: index)
                    }
                }
            }
        }
    }

    private var saveBar: some View {
        VStack(spacing: AppSpacing.xxs) {
            if let validationMessage {
                Text(validationMessage)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }

            PrimaryButton("Save Recipe", systemImage: "checkmark", style: .olive) {
                saveRecipe()
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.55)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [
                    AppColors.appBackground.opacity(0.26),
                    AppColors.appBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var canSave: Bool {
        !titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && ingredientDrafts.contains(where: { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        && instructionSteps.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        && servings > 0
    }

    private var ingredientIndices: [Int] {
        Array(ingredientRows.indices)
    }

    private var instructionIndices: [Int] {
        Array(instructionSteps.indices)
    }

    private var ingredientDrafts: [IngredientDraft] {
        ingredientRows.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !$0.quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func labeledField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)

            TextField(
                "",
                text: text,
                prompt: Text(placeholder).foregroundStyle(AppColors.tertiaryText)
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.primaryText)
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColors.appBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
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

    private func sectionHeader(title: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColors.primaryText)

            Spacer(minLength: AppSpacing.md)

            Button(action: action) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "plus")
                    Text(actionTitle)
                }
                .font(AppTypography.smallButton)
                .foregroundStyle(AppColors.olive)
            }
            .buttonStyle(.plain)
        }
    }

    private func ingredientRow(at index: Int) -> some View {
        let row = binding(for: index)
        let suggestions = ingredientSuggestions(for: row.wrappedValue)

        return HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                TextField(
                    "",
                    text: Binding(
                        get: { row.wrappedValue.name },
                        set: { newValue in
                            var draft = row.wrappedValue
                            draft.updateName(newValue)
                            row.wrappedValue = draft
                        }
                    ),
                    prompt: Text("Ingredient name").foregroundStyle(AppColors.tertiaryText)
                )
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColors.appBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )

                if !suggestions.isEmpty || !row.wrappedValue.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        if !suggestions.isEmpty {
                            ForEach(suggestions, id: \.id) { suggestion in
                                Button {
                                    applySuggestion(suggestion, to: index)
                                } label: {
                                    HStack(spacing: AppSpacing.xxs) {
                                        Image(systemName: row.wrappedValue.matches(suggestion) ? "checkmark.circle.fill" : "circle")
                                            .font(AppTypography.metadata)

                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(suggestion.displayName)
                                                .font(AppTypography.metadata)
                                                .foregroundStyle(AppColors.primaryText)
                                                .lineLimit(1)

                                            Text(suggestion.category)
                                                .font(AppTypography.metadata)
                                                .foregroundStyle(AppColors.secondaryText)
                                                .lineLimit(1)
                                        }

                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, AppSpacing.xxs)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                            .fill(AppColors.softOlive.opacity(0.45))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !row.wrappedValue.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button {
                                markAsCustomIngredient(at: index)
                            } label: {
                                Text("Use custom ingredient")
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                TextField(
                    "",
                    text: Binding(
                        get: { row.wrappedValue.quantity },
                        set: { row.wrappedValue.quantity = $0 }
                    ),
                    prompt: Text("Quantity").foregroundStyle(AppColors.tertiaryText)
                )
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.sm)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColors.appBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
            }

            Button {
                removeIngredientRow(at: index)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }

    private func instructionRow(at index: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Step \(index + 1)")
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColors.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                            .stroke(AppColors.warmBorder, lineWidth: 1)
                    )

                TextEditor(text: Binding(
                    get: { instructionStep(at: index) },
                    set: { setInstructionStep($0, at: index) }
                ))
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 72)
            }
            .frame(minHeight: 88)

            HStack {
                Spacer()

                Button {
                    removeInstructionStep(at: index)
                } label: {
                    Text("Delete step")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func addIngredientRow() {
        ingredientRows.append(IngredientDraft())
    }

    private func removeIngredientRow(at index: Int) {
        guard ingredientRows.indices.contains(index) else { return }
        ingredientRows.remove(at: index)

        if ingredientRows.isEmpty {
            ingredientRows = [IngredientDraft()]
        }
    }

    private func addInstructionStep() {
        instructionSteps.append("")
    }

    private func removeInstructionStep(at index: Int) {
        guard instructionSteps.indices.contains(index) else { return }
        instructionSteps.remove(at: index)

        if instructionSteps.isEmpty {
            instructionSteps = [""]
        }
    }

    private func loadPhoto(from item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    return
                }

                await MainActor.run {
                    selectedPhotoData = data
                    #if canImport(UIKit)
                    selectedPhotoImage = UIImage(data: data)
                    #endif
                }
            } catch {
                print("AddRecipeView: photo selection failed: \(error)")
            }
        }
    }

    private func saveRecipe() {
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationMessage = "Recipe name is required."
            return
        }

        var structuredIngredients: [RecipeIngredient] = []
        for entry in ingredientDrafts {
            let trimmedName = entry.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { continue }

            let parsed = parseQuantity(entry.quantity)
            let catalogItem: ShoppingIngredientCatalogItem?
            if let selectedCatalogIngredientID = entry.selectedCatalogIngredientID {
                catalogItem = ingredientCatalogItem(for: selectedCatalogIngredientID)
            } else {
                catalogItem = nil
            }

            structuredIngredients.append(
                RecipeIngredient(
                    name: catalogItem?.displayName ?? entry.name.localizedCapitalized,
                    quantity: parsed.quantity,
                    unit: parsed.unit.isEmpty ? (catalogItem?.defaultUnit ?? "") : parsed.unit,
                    category: catalogItem?.category ?? "Other",
                    notes: nil,
                    displayQuantity: entry.quantity.trimmingCharacters(in: .whitespacesAndNewlines),
                    catalogIngredientID: catalogItem?.id,
                    catalogNormalizedName: catalogItem?.normalizedName ?? IngredientSuggestionEngine.normalize(entry.name),
                    isCustomIngredient: catalogItem == nil || entry.isCustomIngredient
                )
            )
        }

        guard !structuredIngredients.isEmpty else {
            validationMessage = "Add at least one ingredient."
            return
        }

        let instructions = instructionSteps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !instructions.isEmpty else {
            validationMessage = "Add at least one instruction."
            return
        }

        let imageName = selectedPhotoData.flatMap { RecipeImageStore.shared.saveImageData($0) }
        let trimmedSubcategory = subcategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        let subcategoryID = trimmedSubcategory.isEmpty ? nil : trimmedSubcategory

        let recipe = Recipe.userCreated(
            title: trimmedTitle,
            description: "Created in Flame & Fleur",
            categoryGroupID: "my-recipes",
            subcategoryID: subcategoryID,
            subcategoryTitle: trimmedSubcategory.isEmpty ? "My Recipes" : trimmedSubcategory,
            category: .pantry,
            servings: servings,
            imageName: imageName,
            ingredients: structuredIngredients,
            instructions: instructions
        )

        userRecipeStore.saveUserRecipe(recipe)
        dismiss()
    }

    private func parseQuantity(_ text: String) -> (quantity: Double, unit: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (1, "")
        }

        let parts = trimmed.split(whereSeparator: \.isWhitespace)
        guard let first = parts.first else {
            return (1, "")
        }

        let quantity = parseNumberToken(String(first)) ?? 1
        let unit = parts.dropFirst().joined(separator: " ")
        return (quantity, unit)
    }

    private func parseNumberToken(_ token: String) -> Double? {
        if token.contains("/") {
            let components = token.split(separator: "/")
            guard components.count == 2,
                  let numerator = Double(components[0]),
                  let denominator = Double(components[1]),
                  denominator != 0 else {
                return nil
            }
            return numerator / denominator
        }

        return Double(token)
    }
    
    private func ingredientSuggestions(for draft: IngredientDraft) -> [ShoppingIngredientCatalogItem] {
        IngredientSuggestionEngine.suggestions(for: draft.name)
    }

    private func applySuggestion(_ suggestion: ShoppingIngredientCatalogItem, to index: Int) {
        guard ingredientRows.indices.contains(index) else { return }
        ingredientRows[index].applySelection(suggestion)
    }

    private func markAsCustomIngredient(at index: Int) {
        guard ingredientRows.indices.contains(index) else { return }
        ingredientRows[index].applyCustomIngredientState()
    }

    private func binding(for index: Int) -> Binding<IngredientDraft> {
        Binding(
            get: {
                ingredientRows.indices.contains(index) ? ingredientRows[index] : IngredientDraft()
            },
            set: { newValue in
                guard ingredientRows.indices.contains(index) else { return }
                ingredientRows[index] = newValue
            }
        )
    }

    private func ingredientCatalogItem(for id: String) -> ShoppingIngredientCatalogItem? {
        SampleShoppingIngredientCatalog.all.first { $0.id == id }
    }

    private func instructionStep(at index: Int) -> String {
        instructionSteps.indices.contains(index) ? instructionSteps[index] : ""
    }

    private func setInstructionStep(_ value: String, at index: Int) {
        guard instructionSteps.indices.contains(index) else { return }
        instructionSteps[index] = value
    }
}

private struct IngredientDraft: Identifiable, Hashable {
    let id: UUID
    var name: String
    var quantity: String
    var selectedCatalogIngredientID: String?
    var selectedCatalogNormalizedName: String?
    var isCustomIngredient: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        quantity: String = "",
        selectedCatalogIngredientID: String? = nil,
        selectedCatalogNormalizedName: String? = nil,
        isCustomIngredient: Bool = true
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.selectedCatalogIngredientID = selectedCatalogIngredientID
        self.selectedCatalogNormalizedName = selectedCatalogNormalizedName
        self.isCustomIngredient = isCustomIngredient
    }

    mutating func applyCustomIngredientState() {
        selectedCatalogIngredientID = nil
        selectedCatalogNormalizedName = IngredientSuggestionEngine.normalize(name)
        isCustomIngredient = true
    }

    mutating func updateName(_ newValue: String) {
        name = newValue
        applyCustomIngredientState()
    }

    mutating func applySelection(_ suggestion: ShoppingIngredientCatalogItem) {
        name = suggestion.displayName
        selectedCatalogIngredientID = suggestion.id
        selectedCatalogNormalizedName = suggestion.normalizedName
        isCustomIngredient = false
    }

    func matches(_ suggestion: ShoppingIngredientCatalogItem) -> Bool {
        selectedCatalogIngredientID == suggestion.id
        || selectedCatalogNormalizedName == suggestion.normalizedName
        || IngredientSuggestionEngine.normalize(name) == suggestion.normalizedName
    }
}

#Preview {
    AddRecipeView()
        .environmentObject(UserRecipeStore.shared)
}
