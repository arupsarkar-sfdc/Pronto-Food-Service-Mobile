import SwiftUI

// MARK: - Home Best Sellers Section
struct HomeBestSellersSection: View {
    @State private var pressedProductId: String? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(alignment: .center) {
                Text("Best Sellers")
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
            
            // Grid of Products
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Product.bestSellers) { product in
                    ModernProductCard(
                        product: product,
                        isPressed: pressedProductId == product.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pressedProductId = product.id
                        }
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Track product view
                        trackProductView(product)
                        
                        // Reset after brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                pressedProductId = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Product View Tracking
    private func trackProductView(_ product: Product) {
        print("🍕 Product tapped: \(product.name)")
        print("   Product ID: \(product.id)")
        print("   Price: $\(product.price)")
        print("   Category: \(product.category.rawValue)")
        print("   Rating: \(product.rating)")
        
        // Track to Data Cloud via EngagementTrackingService
        // Mobile SDK CatalogObject mapping:
        //   - "catalogObjectId" → CatalogObject.id → catalogObjectId in wire format (use name, not ID)
        //   - "type" → CatalogObject.type → catalogObjectType in wire format
        //   - "interactionName" + other attrs → CatalogObject.attributes → flow through to payload
        EngagementTrackingService.shared.trackEvent(
            type: .catalog(.view),
            attributes: [
                "catalogObjectId": product.name,  // Use product name (e.g., "Margherita Pizza")
                "type": "Product",
                "interactionName": "View Product \(product.name)",
                "name": product.name,
                "price": product.price,
                "category": product.category.rawValue,
                "sizes": ["Small", "Medium", "Large"],
                "skus": ["\(product.id)-S", "\(product.id)-M", "\(product.id)-L"]
            ]
        )
    }
}

// MARK: - Modern Product Card
struct ModernProductCard: View {
    let product: Product
    let isPressed: Bool
    @State private var showAddButton = false
    @State private var isAddingToCart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Container - properly clipped with GeometryReader
            ZStack(alignment: .topTrailing) {
                // Product Image - use GeometryReader for proper fill
                GeometryReader { geometry in
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                // Loading placeholder
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(.systemGray5), Color(.systemGray4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        ProgressView()
                                            .tint(.gray)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            case .failure:
                                // Fallback to emoji
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        Text(product.emoji)
                                            .font(.system(size: 48))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Fallback gradient with emoji
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.3),
                                        Color.red.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Text(product.emoji)
                                    .font(.system(size: 48))
                            )
                    }
                }
                .frame(height: 140)
                .clipped()
                
                // Rating Badge (bottom right)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0))
                    
                    Text(product.formattedRating)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                
                // Add to Cart Button (top right)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAddingToCart = true
                    }
                    
                    // Haptic
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Track add to cart
                    trackAddToCart(product)
                    
                    // Reset animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            isAddingToCart = false
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: isAddingToCart ? "checkmark" : "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isAddingToCart ? .green : Color(red: 1.0, green: 0.27, blue: 0))
                            .scaleEffect(isAddingToCart ? 1.2 : 1.0)
                    }
                    .frame(width: 36, height: 36)
                }
                .padding(10)
                .opacity(showAddButton ? 1 : 0)
                .scaleEffect(showAddButton ? 1 : 0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(product.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                // Meta info
                HStack(spacing: 4) {
                    Text("\(product.prepTime) min")
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(product.category == .burger || product.category == .pizza ? "$0.99 delivery" : "Free delivery")
                        .foregroundColor(.secondary)
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                
                // Price
                Text(product.formattedPrice)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 4)
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(
            color: .black.opacity(0.06),
            radius: isPressed ? 2 : 8,
            x: 0,
            y: isPressed ? 1 : 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                showAddButton = hovering
            }
        }
        .onAppear {
            // On iOS, always show the add button since there's no hover
            #if os(iOS)
            showAddButton = true
            #endif
        }
    }
    
    // MARK: - Add to Cart Tracking
    private func trackAddToCart(_ product: Product) {
        print("🛒 Added to cart: \(product.name)")
        
        EngagementTrackingService.shared.trackEvent(
            type: .cart(.addToCart),
            attributes: [
                "catalogObjectId": product.name,
                "catalogObjectType": "Product",
                "price": product.price,
                "quantity": 1,
                "currency": product.currency
            ]
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        HomeBestSellersSection()
            .padding(20)
    }
    .background(Color(.systemGroupedBackground))
}
