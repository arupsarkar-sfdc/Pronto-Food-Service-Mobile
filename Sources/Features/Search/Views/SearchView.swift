import SwiftUI
import MapKit

// MARK: - Search View

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7897, longitude: -122.4010), // SF 94105
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map View
                Map(coordinateRegion: $region, annotationItems: viewModel.filteredStoreFronts) { storeFront in
                    MapAnnotation(coordinate: storeFront.coordinate) {
                        StoreFrontMarker(storeFront: storeFront) {
                            viewModel.selectStoreFront(storeFront)
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Overlay Controls
                VStack(spacing: 12) {
                    // Category Filter Pills
                    categoryFilterBar
                    
                    Spacer()
                    
                    // Results Count
                    if !viewModel.searchText.isEmpty || viewModel.selectedCategory != nil {
                        resultsCountBadge
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    searchBarCompact
                }
                
                if !viewModel.searchText.isEmpty || viewModel.selectedCategory != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.clearFilters()
                        }) {
                            Text("Clear")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingDetail) {
                if let storeFront = viewModel.selectedStoreFront {
                    StoreFrontDetailView(storeFront: storeFront)
                }
            }
        }
    }
    
    // MARK: - Compact Search Bar (for Navigation Bar)
    
    private var searchBarCompact: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .medium))
            
            TextField("Search restaurants, food...", text: $viewModel.searchText)
                .font(.system(size: 16, weight: .regular))
                .textFieldStyle(.plain)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .frame(maxWidth: 400)
    }
    
    // MARK: - Category Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StoreCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        if viewModel.selectedCategory == category {
                            viewModel.selectCategory(nil)
                        } else {
                            viewModel.selectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Results Count Badge
    
    private var resultsCountBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.and.ellipse")
                .font(.caption)
            Text("\(viewModel.filteredStoreFronts.count) restaurants found")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.blue)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
        .padding(.bottom, 20)
    }
}

// MARK: - StoreFront Marker

struct StoreFrontMarker: View {
    let storeFront: StoreFront
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                
                Text(storeFront.emoji)
                    .font(.system(size: 28))
            }
            
            Text(storeFront.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 1)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let category: StoreCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(category.icon)
                    .font(.system(size: 16))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 1)
        }
    }
}

// MARK: - StoreFront Detail View

struct StoreFrontDetailView: View {
    let storeFront: StoreFront
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text(storeFront.emoji)
                            .font(.system(size: 80))
                        
                        Text(storeFront.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text(storeFront.category.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(storeFront.formattedRating)
                                .font(.system(size: 16, weight: .semibold))
                            Text("(\(storeFront.reviewCount) reviews)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(icon: "mappin.circle.fill", title: "Address", value: storeFront.fullAddress)
                        DetailRow(icon: "phone.fill", title: "Phone", value: storeFront.phone)
                        DetailRow(icon: "clock.fill", title: "Delivery Time", value: "\(storeFront.deliveryTime) min")
                        DetailRow(icon: "dollarsign.circle.fill", title: "Delivery Fee", value: String(format: "$%.2f", storeFront.deliveryFee))
                        DetailRow(icon: "cart.fill", title: "Minimum Order", value: String(format: "$%.2f", storeFront.minimumOrder))
                        
                        if storeFront.isOpen {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Open Now")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Closed")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Available Products
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Items")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)
                        
                        ForEach(storeFront.getProducts(), id: \.id) { product in
                            ProductRowView(product: product)
                        }
                    }
                }
            }
            .navigationTitle("Restaurant Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Product Row View

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            Text(product.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .semibold))
                Text(product.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(product.formattedPrice)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
