import Foundation

struct ExploreCategoryRepository {
    static let shared = ExploreCategoryRepository()

    let allGroups: [ExploreCategoryGroup]

    init(allGroups: [ExploreCategoryGroup] = SampleExploreCategories.groups) {
        self.allGroups = allGroups
    }

    func group(id: String) -> ExploreCategoryGroup? {
        allGroups.first { $0.id == id }
    }

    func subcategories(for groupID: String) -> [ExploreSubcategory] {
        group(id: groupID)?.subcategories ?? []
    }

    func subcategory(id: String) -> ExploreSubcategory? {
        allGroups
            .lazy
            .flatMap(\.subcategories)
            .first { $0.id == id }
    }
}
