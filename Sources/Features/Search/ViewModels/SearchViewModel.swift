//
//  SearchViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for search functionality with map and storefront filtering
//

import Foundation
import CoreLocation
import Combine

// MARK: - Search ViewModel

@MainActor
public final class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Search query text
    @Published public var searchText: String = ""
    
    /// All available storefronts
    @Published public var allStoreFronts: [StoreFront] = []
    
    /// Filtered storefronts based on search
    @Published public var filteredStoreFronts: [StoreFront] = []
    
    /// Selected storefront for detail view
    @Published public var selectedStoreFront: StoreFront?
    
    /// Show detail sheet
    @Published public var showingDetail: Bool = false
    
    /// User's current location
    @Published public var userLocation: CLLocationCoordinate2D?
    
    /// Selected category filter
    @Published public var selectedCategory: StoreCategory?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        loadStoreFronts()
        setupSearchObserver()
    }
    
    // MARK: - Data Loading
    
    private func loadStoreFronts() {
        allStoreFronts = StoreFront.samples
        filteredStoreFronts = allStoreFronts
    }
    
    // MARK: - Search Functionality
    
    private func setupSearchObserver() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .combineLatest($selectedCategory)
            .sink { [weak self] searchText, category in
                self?.filterStoreFronts(searchText: searchText, category: category)
            }
            .store(in: &cancellables)
    }
    
    private func filterStoreFronts(searchText: String, category: StoreCategory?) {
        var results = allStoreFronts
        
        // Filter by category if selected
        if let category = category {
            results = results.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            results = results.filter { storeFront in
                storeFront.name.localizedCaseInsensitiveContains(searchText) ||
                storeFront.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                storeFront.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredStoreFronts = results
    }
    
    // MARK: - StoreFront Selection
    
    public func selectStoreFront(_ storeFront: StoreFront) {
        selectedStoreFront = storeFront
        showingDetail = true
        
        // Log for debugging (will be replaced with Data Cloud event)
        print("🏪 StoreFront Tapped: \(storeFront.name)")
        print("   ID: \(storeFront.id)")
        print("   Category: \(storeFront.category.rawValue)")
        print("   Location: \(storeFront.latitude), \(storeFront.longitude)")
        print("   📊 TODO: Track to Data Cloud as store interaction event")
    }
    
    // MARK: - Category Filtering
    
    public func selectCategory(_ category: StoreCategory?) {
        selectedCategory = category
    }
    
    public func clearFilters() {
        searchText = ""
        selectedCategory = nil
    }
    
    // MARK: - Location
    
    public func updateUserLocation(_ location: CLLocationCoordinate2D) {
        userLocation = location
    }
}

