import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CartCategoryIconView: View {
    let category: ShoppingCartCategory
    let size: CGFloat

    init(category: ShoppingCartCategory, size: CGFloat = 36) {
        self.category = category
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.softOlive.opacity(0.46))
                .overlay(
                    Circle()
                        .stroke(AppColors.warmBorder, lineWidth: 1)
                )

            iconImage
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var iconImage: some View {
        let assetName = CartCategoryIconResolver.assetName(for: category)

        #if canImport(UIKit)
        if UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .clipped()
        } else {
            Image(systemName: CartCategoryIconResolver.fallbackSystemImageName(for: category))
                .font(.system(size: size * 0.40, weight: .semibold))
                .foregroundStyle(CartCategoryIconResolver.tintColor(for: category))
        }
        #else
        Image(systemName: CartCategoryIconResolver.fallbackSystemImageName(for: category))
            .font(.system(size: size * 0.40, weight: .semibold))
            .foregroundStyle(CartCategoryIconResolver.tintColor(for: category))
        #endif
    }
}

#Preview {
    HStack {
        CartCategoryIconView(category: .produce)
        CartCategoryIconView(category: .protein)
        CartCategoryIconView(category: .bakery)
    }
    .padding()
    .background(AppColors.appBackground)
}
