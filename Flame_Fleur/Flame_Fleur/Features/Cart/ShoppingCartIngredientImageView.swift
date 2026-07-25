import SwiftUI

struct ShoppingCartIngredientImageView: View {
    let item: ShoppingCartItem
    let size: CGFloat

    init(item: ShoppingCartItem, size: CGFloat = 48) {
        self.item = item
        self.size = size
    }

    var body: some View {
        FoodImagePlaceholder(
            imageName: ShoppingCartIngredientImageResolver.imageName(for: item),
            style: .circle
        )
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

private enum ShoppingCartIngredientImageResolver {
    static func imageName(for item: ShoppingCartItem) -> String {
        if let catalogImageName = SampleShoppingIngredientCatalog.byNormalizedName[item.normalizedName]?.imageName?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !catalogImageName.isEmpty {
            return catalogImageName
        }

        if let itemImageName = item.imageName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !itemImageName.isEmpty {
            return itemImageName
        }

        return CartCategoryIconResolver.assetName(for: item.category)
    }
}

#Preview {
    ShoppingCartIngredientImageView(item: SampleShoppingCartItems.currentWeek[0])
        .padding()
        .background(AppColors.appBackground)
}
