import SwiftUI

public struct ProductRecommendationsView: View {
    let model: ProductRecommendationsModel
    
    @State private var pressedRestaurantId: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var restaurants: [Restaurant] {
        var result: [Restaurant] = []
        
        //convert items to restaurants
        
        for i in model.items {
            print("SFP: Recommended Item: " + i.id)
            let r = Restaurant(id: i.id, name: i.name, cuisine: "", priceLevel: "", rating: 4.5, description: i.description, imageUrl: i.imageUrl, prepTime: "20 min", deliveryFee: "free", badge: nil)
            
            result.append(r)
        }
        
        return result
    }

    public init(model: ProductRecommendationsModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text(model.sectionHeader ?? "")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .tracking(-0.5)

                Spacer()

                Button(action: {}) {
                    Text("See All")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 1.0, green: 0.27, blue: 0).opacity(0.1))
                        )
                }
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(restaurants) { restaurant in
                    RestaurantCard(
                        restaurant: restaurant,
                        isPressed: pressedRestaurantId == restaurant.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pressedRestaurantId = restaurant.id
                        }
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()

                        trackRestaurantView(restaurant)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                pressedRestaurantId = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func trackRestaurantView(_ r: Restaurant) {
        print("🍽️ Restaurant tapped: \(r.name) [\(r.id)]")

        EngagementTrackingService.shared.trackEvent(
            type: .catalog(.view),
            attributes: [
                "catalogObjectId": r.id,
                "type": "Restaurant",
                "interactionName": "View Catalog Object",
                "name": r.name,
                "cuisine": r.cuisine,
                "priceLevel": r.priceLevel,
                "rating": r.rating
            ]
        )
    }
}

