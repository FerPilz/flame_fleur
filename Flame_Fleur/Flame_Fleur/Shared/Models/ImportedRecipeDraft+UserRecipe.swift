import Foundation

extension ImportedRecipeDraft {
    func validationErrorsForUserRecipe() -> [ImportedRecipeDraftValidationError] {
        var errors: [ImportedRecipeDraftValidationError] = []

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.missingTitle)
        }

        if cleanedIngredients.isEmpty {
            errors.append(.missingIngredients)
        }

        if cleanedInstructions.isEmpty {
            errors.append(.missingInstructions)
        }

        return errors
    }

    func makeUserRecipe(
        now: Date = Date(),
        localImageName: String? = nil
    ) throws -> Recipe {
        let errors = validationErrorsForUserRecipe()
        guard errors.isEmpty else {
            throw errors[0]
        }

        let sourceHostText = sourceHost?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
            ?? sourceURL.host
        let description = sourceHostText.map { "Imported from \($0)" } ?? "Imported recipe"
        let importedDate = importedAt

        return Recipe.userCreated(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description,
            categoryGroupID: "my-recipes",
            subcategoryID: "my-recipes",
            subcategoryTitle: "My Recipes",
            category: .pantry,
            servings: max(servings ?? 1, 1),
            prepTimeMinutes: max(prepTimeMinutes ?? 0, 0),
            cookingTimeMinutes: max(cookTimeMinutes ?? 0, 0),
            totalTimeMinutes: resolvedTotalTimeMinutes.map { max($0, 0) },
            tags: ["imported"],
            imageName: localImageName?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
                ?? self.localImageName?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty,
            remoteImageURLString: imageURL?.absoluteString,
            userRecipeSourceType: .importedURL,
            sourceURLString: sourceURL.absoluteString,
            sourceHost: sourceHostText,
            importedAt: importedDate,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty,
            ingredients: cleanedIngredients,
            instructions: cleanedInstructions
        )
    }

    private var cleanedIngredients: [RecipeIngredient] {
        ingredients.compactMap { draftIngredient in
            let rawText = draftIngredient.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedName = draftIngredient.name.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
                ?? rawText.nonEmpty

            guard let resolvedName else {
                return nil
            }

            return RecipeIngredient(
                id: draftIngredient.id,
                name: resolvedName,
                quantity: draftIngredient.quantity ?? 1,
                unit: draftIngredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                category: "",
                notes: nil,
                rawText: rawText.nonEmpty ?? resolvedName,
                displayQuantity: displayQuantity(for: draftIngredient),
                catalogIngredientID: draftIngredient.matchedCatalogItemID,
                catalogNormalizedName: nil,
                isCustomIngredient: draftIngredient.matchedCatalogItemID == nil
            )
        }
    }

    private var cleanedInstructions: [String] {
        instructions
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func displayQuantity(for ingredient: ImportedIngredientDraft) -> String {
        let quantity = ingredient.quantity.map(Self.formatQuantity) ?? ""
        let unit = ingredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return [quantity, unit]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    nonisolated private static func formatQuantity(_ quantity: Double) -> String {
        let rounded = quantity.rounded()
        if abs(quantity - rounded) < 0.001 {
            return String(Int(rounded))
        }

        return String(format: "%.2f", quantity)
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
