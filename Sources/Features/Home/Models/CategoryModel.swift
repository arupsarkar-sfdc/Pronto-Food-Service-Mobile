import Foundation

// MARK: - Food Category Model
struct FoodCategory: Identifiable, Codable {
    let id: Int
    let name: String
    let icon: String
    let isActive: Bool
    
    init(id: Int, name: String, icon: String, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isActive = isActive
    }
}

// MARK: - Default Categories
extension FoodCategory {
    static let defaultCategories: [FoodCategory] = [
        FoodCategory(id: 0, name: "Meat", icon: "🥩"),
        FoodCategory(id: 1, name: "Fast Food", icon: "🍔"),
        FoodCategory(id: 2, name: "Sushi", icon: "🍣"),
        FoodCategory(id: 3, name: "Drinks", icon: "🥤")
    ]
}

