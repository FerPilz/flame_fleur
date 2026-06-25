import SwiftUI

struct RecipeImportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userRecipeStore: UserRecipeStore

    @State private var draft: ImportedRecipeDraft
    @State private var saveMessage: String?
    @State private var isSaving = false
    @State private var hasSaved = false

    let warnings: [RecipeImportWarning]
    private let imageDownloadService = RecipeImageDownloadService.shared

    init(draft: ImportedRecipeDraft, warnings: [RecipeImportWarning] = []) {
        _draft = State(initialValue: draft)
        self.warnings = warnings
    }

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        heroImageSection
                        basicsSection
                        ingredientsSection
                        instructionsSection
                        sourceSection
                        warningsSection
                        saveMessageSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.sm)
                }

                bottomBar
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            HStack {
                IconCircleButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Cancel",
                    size: AppTopActionMetrics.buttonSize,
                    action: { dismiss() }
                )

                Spacer()
            }

            Text("Review Import")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.sm)
        .frame(height: 52)
    }

    private var heroImageSection: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.hero,
            contentPadding: 0,
            showsShadow: false
        ) {
            ZStack {
                if let imageURL = draft.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            placeholderView
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipped()
                        case .failure:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous))
        }
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.hero, style: .continuous)
                .fill(AppColors.softOlive.opacity(0.18))
                .frame(height: 240)

            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "book.closed")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppColors.olive)

                Text("No image provided")
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var basicsSection: some View {
        SurfaceCard(
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sectionHeader("Basics")

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    labeledField(title: "Recipe title") {
                        TextField("Recipe title", text: $draft.title)
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.primaryText)
                            .textInputAutocapitalization(.words)
                    }

                    HStack(spacing: AppSpacing.sm) {
                        labeledStepperField(title: "Servings", value: Binding(
                            get: { draft.servings ?? 1 },
                            set: { draft.servings = max(1, $0) }
                        ))

                        labeledNumberField(
                            title: "Prep",
                            value: Binding(
                                get: { draft.prepTimeMinutes.map(String.init) ?? "" },
                                set: { draft.prepTimeMinutes = Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                            ),
                            placeholder: "mins"
                        )

                        labeledNumberField(
                            title: "Cook",
                            value: Binding(
                                get: { draft.cookTimeMinutes.map(String.init) ?? "" },
                                set: { draft.cookTimeMinutes = Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                            ),
                            placeholder: "mins"
                        )
                    }
                }
            }
        }
    }

    private var ingredientsSection: some View {
        SurfaceCard(
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    sectionHeader("Ingredients")

                    Spacer()

                    Button {
                        draft.ingredients.append(ImportedIngredientDraft(rawText: ""))
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)
                    }
                    .buttonStyle(.plain)
                }

                if draft.ingredients.isEmpty {
                    Text("Add the ingredients you want to keep with this recipe.")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                VStack(spacing: AppSpacing.sm) {
                    ForEach($draft.ingredients) { $ingredient in
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            HStack(alignment: .center, spacing: AppSpacing.sm) {
                                TextField("Ingredient", text: $ingredient.rawText)
                                    .font(AppTypography.callout)
                                    .foregroundStyle(AppColors.primaryText)

                                Button {
                                    draft.ingredients.removeAll { $0.id == ingredient.id }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.tertiaryText)
                                }
                                .buttonStyle(.plain)
                            }

                            if ingredient.isMatched {
                                Text("Matched ingredient")
                                    .font(AppTypography.metadata)
                                    .foregroundStyle(AppColors.olive)
                            }
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                .fill(AppColors.elevatedCardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                .stroke(AppColors.warmBorder, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var instructionsSection: some View {
        SurfaceCard(
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    sectionHeader("Instructions")

                    Spacer()

                    Button {
                        draft.instructions.append("")
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(AppTypography.metadata)
                            .foregroundStyle(AppColors.olive)
                    }
                    .buttonStyle(.plain)
                }

                if draft.instructions.isEmpty {
                    Text("Add the steps that belong to this recipe.")
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                }

                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(draft.instructions.indices), id: \.self) { index in
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            HStack(alignment: .top, spacing: AppSpacing.sm) {
                                Text("\(index + 1).")
                                    .font(AppTypography.bodyEmphasis)
                                    .foregroundStyle(AppColors.olive)
                                    .frame(width: 24, alignment: .leading)

                                TextField("Step", text: Binding(
                                    get: { draft.instructions[index] },
                                    set: { draft.instructions[index] = $0 }
                                ), axis: .vertical)
                                .font(AppTypography.callout)
                                .foregroundStyle(AppColors.primaryText)

                                Button {
                                    draft.instructions.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.tertiaryText)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                .fill(AppColors.elevatedCardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                                .stroke(AppColors.warmBorder, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var sourceSection: some View {
        SurfaceCard(
            backgroundColor: AppColors.cardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md,
            showsShadow: false
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                sectionHeader("Source")

                Text(draft.sourceURL.absoluteString)
                    .font(AppTypography.metadata)
                    .foregroundStyle(AppColors.secondaryText)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var warningsSection: some View {
        Group {
            if !warnings.isEmpty {
                SurfaceCard(
                    backgroundColor: AppColors.softOrange.opacity(0.18),
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.md,
                    showsShadow: false
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        sectionHeader("Warnings")

                        ForEach(warnings, id: \.self) { warning in
                            Text(warning.displayText)
                                .font(AppTypography.metadata)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private var saveMessageSection: some View {
        Group {
            if let saveMessage {
                SurfaceCard(
                    backgroundColor: AppColors.softOlive.opacity(0.18),
                    borderColor: AppColors.warmBorder,
                    cornerRadius: AppRadius.large,
                    contentPadding: AppSpacing.md,
                    showsShadow: false
                ) {
                    Text(saveMessage)
                        .font(AppTypography.metadata)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var bottomBar: some View {
        SurfaceCard(
            backgroundColor: AppColors.elevatedCardBackground,
            borderColor: AppColors.warmBorder,
            cornerRadius: AppRadius.large,
            contentPadding: AppSpacing.md,
            showsShadow: false
        ) {
            HStack(spacing: AppSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(AppTypography.button)
                        .foregroundStyle(AppColors.olive)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule(style: .continuous)
                                .stroke(AppColors.warmBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                PrimaryButton(saveButtonTitle, systemImage: "checkmark", style: .recipe) {
                    saveTapped()
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.md)
    }

    private var canSave: Bool {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasIngredients = draft.ingredients.contains { !$0.rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let hasInstructions = draft.instructions.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return !isSaving && !hasSaved && !title.isEmpty && hasIngredients && hasInstructions
    }

    private var saveButtonTitle: String {
        if isSaving {
            return "Saving..."
        }

        if hasSaved {
            return "Saved"
        }

        return "Save to My Recipes"
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.cardTitle)
            .foregroundStyle(AppColors.primaryText)
    }

    private func labeledField<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)

            content()
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColors.elevatedCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        }
    }

    private func labeledStepperField(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)

            Stepper(value: value, in: 1...12) {
                Text("\(value.wrappedValue)")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(AppColors.elevatedCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColors.warmBorder, lineWidth: 1)
            )
        }
    }

    private func labeledNumberField(title: String, value: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.metadata)
                .foregroundStyle(AppColors.secondaryText)

            TextField(placeholder, text: value)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.primaryText)
                .keyboardType(.numberPad)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .fill(AppColors.elevatedCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )
        }
    }

    private func saveTapped() {
        guard !isSaving, !hasSaved else { return }

        let validationErrors = draft.validationErrorsForUserRecipe()
        guard validationErrors.isEmpty else {
            saveMessage = validationErrors[0].localizedDescription
            return
        }

        isSaving = true
        saveMessage = nil

        Task {
            let localImageName = await imageDownloadService.downloadAndStoreImage(from: draft.imageURL)

            await MainActor.run {
                do {
                    let recipe = try draft.makeUserRecipe(localImageName: localImageName)
                    userRecipeStore.saveUserRecipe(recipe)
                    hasSaved = true

                    if draft.imageURL != nil && localImageName == nil {
                        saveMessage = "Recipe saved to My Recipes. Image could not be saved locally."
                    } else {
                        saveMessage = "Recipe saved to My Recipes."
                    }
                } catch {
                    saveMessage = error.localizedDescription
                }

                isSaving = false
            }
        }
    }
}

#Preview {
    RecipeImportPreviewView(
        draft: ImportedRecipeDraft(
            title: "Creamy Tomato Pasta",
            sourceURL: URL(string: "https://example.com/recipe")!,
            imageURL: URL(string: "https://example.com/image.jpg"),
            servings: 4,
            prepTimeMinutes: 15,
            cookTimeMinutes: 25,
            ingredients: [
                ImportedIngredientDraft(rawText: "8 oz spaghetti"),
                ImportedIngredientDraft(rawText: "2 cups cherry tomatoes")
            ],
            instructions: [
                "Boil the pasta.",
                "Simmer the sauce.",
                "Toss and serve."
            ],
            parserSource: .jsonLD
        ),
        warnings: [.missingImage]
    )
    .environmentObject(UserRecipeStore.shared)
}
