import SwiftUI

// MARK: - Home Category Bar View
// Uses ProductCategory from Core/Models/Product.swift
struct HomeCategoryBarView: View {
    @State private var selectedCategory: ProductCategory? = nil
    private let categories = ProductCategory.homeCategories
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories, id: \.self) { category in
                    HomeCategoryButton(
                        title: category.rawValue,
                        icon: category.emoji,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                        
                        // Track category tap - all categories tracked
                        trackCategoryView(category: category)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }
    
    // MARK: - Category View Tracking
    
    /// Track category view event to Data Cloud
    private func trackCategoryView(category: ProductCategory) {
        print("🔘 Category tapped: \(category.rawValue)")
        print("   Category ID: \(category.catalogId)")
        print("   Icon: \(category.emoji)")
        
        // Track to Data Cloud via EngagementTrackingService
        // Mobile SDK CatalogObject mapping:
        //   - "catalogObjectId" → CatalogObject.id → catalogObjectId in wire format (use name, not ID)
        //   - "type" → CatalogObject.type → catalogObjectType in wire format
        //   - "interactionName" + other attrs → CatalogObject.attributes → flow through to payload
        
        EngagementTrackingService.shared.trackEvent(
            type: .custom("categoryEngagement"),
            attributes: [
                "categoryId": category.rawValue,
                "interactionName": "View Category"
            ]
        )
        
        
        /*EngagementTrackingService.shared.trackEvent(
            type: .catalog(.view),
            attributes: [
                "catalogObjectId": category.rawValue,  // Use category name (e.g., "Pizza", "Sushi")
                "type": "Category",
                "interactionName": "View Category \(category.rawValue)",
                "name": category.rawValue,
                "icon": category.emoji
            ]
        )*/
    }
}

// MARK: - Home Category Button
struct HomeCategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.title2)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.blue],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [Color(.tertiarySystemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? Color.clear : Color(.quaternaryLabel),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 2,
                x: 0,
                y: isSelected ? 4 : 1
            )
        }
    }
}
