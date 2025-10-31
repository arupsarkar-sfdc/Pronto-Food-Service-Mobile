import SwiftUI

// MARK: - Home Best Sellers Section
struct HomeBestSellersSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Best Sellers")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button("See All") {
                    // Handle see all action
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Product.bestSellers) { product in
                        HomeBestSellerCard(
                            product: product
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}

// MARK: - Home Best Seller Card
struct HomeBestSellerCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.3),
                            Color.red.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 100)
                .overlay(
                    Text(product.emoji)
                        .font(.system(size: 32))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                    
                    Text(product.formattedRating)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(product.prepTime) min")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Text(product.formattedPrice)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .frame(width: 140)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.quaternaryLabel), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onTapGesture {
            // Track catalog view event
            trackProductView(product)
        }
    }
    
    // MARK: - Product View Tracking
    
    /// Track product view event to Data Cloud
    private func trackProductView(_ product: Product) {
        print("🍕 Product tapped: \(product.name)")
        print("   Product ID: \(product.id)")
        print("   Price: $\(product.price)")
        print("   Category: \(product.category.rawValue)")
        print("   Rating: \(product.rating)")
        
        // Track to Data Cloud via EngagementTrackingService
        // Match AcmeDigitalStore implementation exactly
        EngagementTrackingService.shared.trackEvent(
            type: .catalog(.view),
            attributes: [
                "catalogObjectId": product.name,
                "type": "ProductBrowse",
                "name": product.id,
                "price": product.price,
                "category": product.category.rawValue,
                "sizes": ["Small", "Medium", "Large"],
                "skus": ["\(product.id)-S", "\(product.id)-M", "\(product.id)-L"]
            ]
        )
    }
}
