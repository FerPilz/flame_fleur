import Combine
import Foundation

final class UserRecipeStore: ObservableObject {
    static let shared = UserRecipeStore()

    @Published private(set) var recipes: [Recipe]

    private let fileManager: FileManager
    private let fileURL: URL

    init(
        fileManager: FileManager = .default,
        fileURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.fileURL = fileURL ?? UserRecipeStore.defaultFileURL(fileManager: fileManager)
        self.recipes = UserRecipeStore.loadRecipes(from: self.fileURL)
    }

    var myRecipes: [Recipe] {
        recipes
    }

    func loadUserRecipes() -> [Recipe] {
        recipes
    }

    func saveUserRecipe(_ recipe: Recipe) {
        guard recipe.isValidUserRecipe else { return }

        var normalizedRecipe = recipe
        if !normalizedRecipe.isUserCreated {
            normalizedRecipe = Recipe(
                id: normalizedRecipe.id,
                title: normalizedRecipe.title,
                subtitle: normalizedRecipe.subtitle,
                description: normalizedRecipe.description,
                categoryGroupID: normalizedRecipe.categoryGroupID,
                subcategoryID: normalizedRecipe.subcategoryID,
                subcategoryTitle: normalizedRecipe.subcategoryTitle,
                creatorName: normalizedRecipe.creatorName,
                creatorAvatarName: normalizedRecipe.creatorAvatarName,
                category: normalizedRecipe.category,
                sectionTags: Array(normalizedRecipe.sectionTags),
                prepTimeMinutes: normalizedRecipe.prepTimeMinutes,
                cookingTimeMinutes: normalizedRecipe.cookingTimeMinutes,
                totalTimeMinutes: normalizedRecipe.totalTimeMinutes,
                calories: normalizedRecipe.calories,
                servings: normalizedRecipe.servings,
                difficulty: normalizedRecipe.difficulty,
                tags: normalizedRecipe.tags,
                imageName: normalizedRecipe.imageName,
                remoteImageURLString: normalizedRecipe.remoteImageURLString,
                userRecipeSourceType: normalizedRecipe.userRecipeSourceType ?? .manualUser,
                sourceURLString: normalizedRecipe.sourceURLString,
                sourceHost: normalizedRecipe.sourceHost,
                importedAt: normalizedRecipe.importedAt,
                notes: normalizedRecipe.notes,
                isPremium: normalizedRecipe.isPremium,
                isCommunityRecipe: normalizedRecipe.isCommunityRecipe,
                isUserCreated: true,
                createdAt: Date(),
                updatedAt: Date(),
                ingredients: normalizedRecipe.ingredients,
                structuredIngredients: normalizedRecipe.structuredIngredients,
                instructions: normalizedRecipe.instructions,
                nutrition: normalizedRecipe.nutrition,
                equipment: normalizedRecipe.equipment,
                tips: normalizedRecipe.tips
            )
        }

        let now = Date()
        let persistedRecipe = Recipe(
            id: normalizedRecipe.id,
            title: normalizedRecipe.title,
            subtitle: normalizedRecipe.subtitle,
            description: normalizedRecipe.description,
            categoryGroupID: normalizedRecipe.categoryGroupID,
            subcategoryID: normalizedRecipe.subcategoryID,
            subcategoryTitle: normalizedRecipe.subcategoryTitle,
            creatorName: normalizedRecipe.creatorName,
            creatorAvatarName: normalizedRecipe.creatorAvatarName,
            category: normalizedRecipe.category,
            sectionTags: Array(normalizedRecipe.sectionTags),
            prepTimeMinutes: normalizedRecipe.prepTimeMinutes,
            cookingTimeMinutes: normalizedRecipe.cookingTimeMinutes,
            totalTimeMinutes: normalizedRecipe.totalTimeMinutes,
            calories: normalizedRecipe.calories,
            servings: normalizedRecipe.servings,
            difficulty: normalizedRecipe.difficulty,
            tags: normalizedRecipe.tags,
            imageName: normalizedRecipe.imageName,
            remoteImageURLString: normalizedRecipe.remoteImageURLString,
            userRecipeSourceType: normalizedRecipe.userRecipeSourceType ?? .manualUser,
            sourceURLString: normalizedRecipe.sourceURLString,
            sourceHost: normalizedRecipe.sourceHost,
            importedAt: normalizedRecipe.importedAt,
            notes: normalizedRecipe.notes,
            isPremium: normalizedRecipe.isPremium,
            isCommunityRecipe: normalizedRecipe.isCommunityRecipe,
            isUserCreated: true,
            createdAt: normalizedRecipe.createdAt ?? now,
            updatedAt: now,
            ingredients: normalizedRecipe.ingredients,
            structuredIngredients: normalizedRecipe.structuredIngredients,
            instructions: normalizedRecipe.instructions,
            nutrition: normalizedRecipe.nutrition,
            equipment: normalizedRecipe.equipment,
            tips: normalizedRecipe.tips
        )

        if let index = recipes.firstIndex(where: { $0.id == persistedRecipe.id }) {
            recipes[index] = persistedRecipe
        } else {
            recipes.insert(persistedRecipe, at: 0)
        }

        persist()
    }

    func updateUserRecipe(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            saveUserRecipe(recipe)
            return
        }

        let updatedRecipe = Recipe(
            id: recipe.id,
            title: recipe.title,
            subtitle: recipe.subtitle,
            description: recipe.description,
            categoryGroupID: recipe.categoryGroupID,
            subcategoryID: recipe.subcategoryID,
            subcategoryTitle: recipe.subcategoryTitle,
            creatorName: recipe.creatorName,
            creatorAvatarName: recipe.creatorAvatarName,
            category: recipe.category,
            sectionTags: Array(recipe.sectionTags),
            prepTimeMinutes: recipe.prepTimeMinutes,
            cookingTimeMinutes: recipe.cookingTimeMinutes,
            totalTimeMinutes: recipe.totalTimeMinutes,
            calories: recipe.calories,
            servings: recipe.servings,
            difficulty: recipe.difficulty,
            tags: recipe.tags,
            imageName: recipe.imageName,
            remoteImageURLString: recipe.remoteImageURLString,
            userRecipeSourceType: recipe.userRecipeSourceType ?? .manualUser,
            sourceURLString: recipe.sourceURLString,
            sourceHost: recipe.sourceHost,
            importedAt: recipe.importedAt,
            notes: recipe.notes,
            isPremium: recipe.isPremium,
            isCommunityRecipe: recipe.isCommunityRecipe,
            isUserCreated: true,
            createdAt: recipes[index].createdAt,
            updatedAt: Date(),
            ingredients: recipe.ingredients,
            structuredIngredients: recipe.structuredIngredients,
            instructions: recipe.instructions,
            nutrition: recipe.nutrition,
            equipment: recipe.equipment,
            tips: recipe.tips
        )

        recipes[index] = updatedRecipe
        persist()
    }

    func deleteUserRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        persist()
    }

    func deleteUserRecipe(id: String) {
        recipes.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        do {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(recipes)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("UserRecipeStore: failed to persist recipes at \(fileURL.lastPathComponent): \(error)")
        }
    }

    private static func loadRecipes(from fileURL: URL) -> [Recipe] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Recipe].self, from: data)
        } catch {
            print("UserRecipeStore: failed to load recipes from disk: \(error)")
            return []
        }
    }

    private static func defaultFileURL(fileManager: FileManager) -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return baseDirectory
            .appendingPathComponent("Flame_Fleur", isDirectory: true)
            .appendingPathComponent("user_recipes.json", isDirectory: false)
    }
}
