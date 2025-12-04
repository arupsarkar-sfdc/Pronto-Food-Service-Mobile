import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = PersonalizationViewModel()
    @State private var dataGraphResult: String = ""
    @State private var showingDataGraphResult = false
    @State private var isLoadingDataGraph = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Low Code Personalization Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Low Code Personalization")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    lowCodePersonalizationCard
                }
                
                // Pro Code Personalization Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Pro Code Personalization")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Refresh button
                        if !viewModel.isLoading {
                            Button(action: {
                                Task {
                                    await viewModel.refresh()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16))
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    proCodePersonalizationCard
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Personalization")
        .navigationBarTitleDisplayMode(.large)
        .task {
            // Fetch personalization with winner selection based on Data Graph clicks
            await viewModel.fetchPersonalizationWithWinner()
        }
        .alert("Data Graph API Response", isPresented: $showingDataGraphResult) {
            Button("OK", role: .cancel) { }
            Button("Copy") {
                UIPasteboard.general.string = dataGraphResult
            }
        } message: {
            Text(dataGraphResult)
        }
        .overlay {
            if isLoadingDataGraph {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Querying Data Graph...")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(32)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 20)
                }
            }
        }
    }
    
    // MARK: - Low Code Personalization Card
    
    private var lowCodePersonalizationCard: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 8)
            
            // Title & Description
            VStack(spacing: 8) {
                Text("Salesforce Personalization Module")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Personalization recommendations powered by Salesforce's low-code solution")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            // Status Badge
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                Text("Coming Soon")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(20)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Pro Code Personalization Card
    
    private var proCodePersonalizationCard: some View {
        VStack(spacing: 0) {
            // Header with Background Image
            ZStack(alignment: .topTrailing) {
                // Background - image or gradient
                if let imageUrlString = viewModel.backgroundImageUrl {
                    let _ = print("🖼️ Image URL from ViewModel: \(imageUrlString)")
                    
                    // Convert Unsplash page URL to direct image URL if needed
                    let directImageUrl = convertToDirectImageUrl(imageUrlString)
                    let _ = print("🖼️ Direct URL after conversion: \(directImageUrl)")
                    
                    if let imageUrl = URL(string: directImageUrl) {
                        let _ = print("🖼️ Valid URL created: \(imageUrl)")
                        AsyncImage(url: imageUrl) { phase in
                            let _ = print("🖼️ AsyncImage phase: \(phase)")
                            switch phase {
                            case .empty:
                                // Loading state - show gradient
                                let _ = print("🖼️ Phase: EMPTY (loading)")
                                ZStack {
                                    gradientBackground
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            case .success(let image):
                                // Image loaded successfully - clean image, no overlays
                                let _ = print("✅ Phase: SUCCESS (image loaded)")
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                                    .clipped()
                            case .failure(let error):
                                // Failed to load - show gradient
                                let _ = print("❌ Phase: FAILURE - \(error.localizedDescription)")
                                gradientBackground
                            @unknown default:
                                let _ = print("⚠️ Phase: UNKNOWN")
                                gradientBackground
                            }
                        }
                    } else {
                        let _ = print("❌ Failed to create URL from: \(directImageUrl)")
                        gradientBackground
                    }
                } else {
                    let _ = print("❌ No backgroundImageUrl in ViewModel")
                    // No image URL - show gradient
                    gradientBackground
                }
                
                // Badges - top right corner
                VStack(alignment: .trailing, spacing: 8) {
                    // Active badge
                    if viewModel.hasData {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Active")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(20)
                    }
                    
//                    // Technology badges
//                    HStack(spacing: 6) {
//                        // Data Graph badge (clickable)
//                        Button(action: {
//                            Task {
//                                await fetchDataGraphData()
//                            }
//                        }) {
//                            Text("Data Graph")
//                                .font(.system(size: 10, weight: .medium))
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 5)
//                                .background(
//                                    Capsule()
//                                        .fill(Color.blue.opacity(0.9))
//                                )
//                        }
//                        .buttonStyle(.borderless)
                        
//                        // SDK badge (clickable)
//                        Button(action: {
//                            print("═══════════════════════════════════════════")
//                            print("🟣 SDK badge tapped!")
//                            print("   Context: Using Salesforce Personalization SDK")
//                            print("   Timestamp: \(Date())")
//                            print("═══════════════════════════════════════════")
//                        }) {
//                            Text("SDK")
//                                .font(.system(size: 10, weight: .medium))
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 5)
//                                .background(
//                                    Capsule()
//                                        .fill(Color.purple.opacity(0.9))
//                                )
//                        }
//                        .buttonStyle(.borderless)
//                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()
            .background(Color.gray.opacity(0.1))
            
            // Content Section - Display Winning Decision
            if let winner = viewModel.winningDecision {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal)
                    
                    // Winner Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🏆 Recommended for You")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Winner Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                // Emoji
                                Text(winner.emoji)
                                    .font(.system(size: 40))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(winner.name)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    if let subheader = winner.subheader {
                                        Text(subheader)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            // Call to Action
                            if let ctaText = winner.callToActionText, 
                               let ctaUrl = winner.callToActionUrl,
                               let url = URL(string: ctaUrl) {
                                Link(destination: url) {
                                    HStack {
                                        Text(ctaText)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        Spacer()
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 18))
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.08))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                }
                .padding(.bottom, 16)
            } else if viewModel.isLoading {
                // Loading state
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    ProgressView("Loading personalization...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            } else if let error = viewModel.errorMessage {
                // Error state
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            } else {
                // No data state
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    Text("No personalization data available yet.\nBrowse the app to get personalized recommendations.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Views
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Helper Methods
    
    /// Convert Unsplash page URL to direct image URL
    private func convertToDirectImageUrl(_ urlString: String) -> String {
        // Check if it's an Unsplash photo page URL
        if urlString.contains("unsplash.com/photos/") {
            // Extract photo ID from URL like: https://unsplash.com/photos/pizza-on-chopping-board-MqT0asuoIcU
            if let photoId = urlString.components(separatedBy: "/").last?.components(separatedBy: "-").last {
                // Convert to direct image URL
                // Using Unsplash Source API for direct image access
                return "https://source.unsplash.com/\(photoId)/800x600"
            }
        }
        
        // If already a direct URL or other format, return as-is
        return urlString
    }
    
    // MARK: - Data Graph Query
    
//    @MainActor
//    private func fetchDataGraphData() async {
//        print("═══════════════════════════════════════════")
//        print("🔵 Data Graph badge tapped!")
//        print("   Starting Data Graph API query...")
//        print("═══════════════════════════════════════════")
//        
//        self.isLoadingDataGraph = true
//        
//        do {
//            let result = try await DataGraphQueryService.shared.queryDataGraph(
//                dataGraphName: "C360_Contact_RT",
//                dmoName: "UnifiedLinkssotIndividualI1__dlm",
//                fieldName: "UnifiedRecordId__c",
//                value: "9ea2aa85ce5b5a1e15498c204306aa76",
//                live: true
//            )
//            
//            // Parse and structure the product browse engagement data
//            let structuredData = parseProductBrowseEngagement(from: result, individualId: "4be44eaae0770cdd")
//            self.dataGraphResult = structuredData
//            
//            print("✅ Data Graph API Response parsed and structured")
//            print(structuredData)
//            
//            self.showingDataGraphResult = true
//            
//        } catch {
//            print("❌ Data Graph query failed: \(error.localizedDescription)")
//            self.dataGraphResult = "Error: \(error.localizedDescription)"
//            self.showingDataGraphResult = true
//        }
//        
//        self.isLoadingDataGraph = false
//        
//        print("═══════════════════════════════════════════")
//    }
    
    // MARK: - Parse Product Browse Engagement
    
    private func parseProductBrowseEngagement(from response: [String: Any], individualId: String) -> String {
        var output = "📊 PRODUCT BROWSE ENGAGEMENT\n"
        output += "═══════════════════════════════════════════\n\n"
        output += "👤 Individual ID: \(individualId)\n"
        output += "🌐 Source: Web Browser (Pronto_Web_Connector)\n\n"
        
        guard let dataArray = response["data"] as? [[String: Any]],
              let firstData = dataArray.first,
              let jsonBlobString = firstData["json_blob__c"] as? String,
              let jsonBlobData = jsonBlobString.data(using: .utf8),
              let jsonBlob = try? JSONSerialization.jsonObject(with: jsonBlobData) as? [String: Any],
              let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]] else {
            return "❌ Unable to parse Data Graph response"
        }
        
        // Find the individual with matching SourceRecordId
        var productEngagements: [String: [(date: Date, id: String)]] = [:]
        
        for link in unifiedLinks {
            guard let sourceRecordId = link["SourceRecordId__c"] as? String,
                  sourceRecordId == individualId,
                  let individuals = link["ssot__Individual__dlm"] as? [[String: Any]] else {
                continue
            }
            
            for individual in individuals {
                guard let engagements = individual["ssot__ProductBrowseEngagement__dlm"] as? [[String: Any]] else {
                    continue
                }
                
                for engagement in engagements {
                    if let productId = engagement["ssot__ProductId__c"] as? String,
                       let createdDateString = engagement["ssot__CreatedDate__c"] as? String,
                       let eventId = engagement["ssot__Id__c"] as? String {
                        
                        let dateFormatter = ISO8601DateFormatter()
                        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        if let date = dateFormatter.date(from: createdDateString) {
                            if productEngagements[productId] == nil {
                                productEngagements[productId] = []
                            }
                            productEngagements[productId]?.append((date: date, id: eventId))
                        }
                    }
                }
            }
        }
        
        // Sort products by total clicks (descending)
        let sortedProducts = productEngagements.sorted { $0.value.count > $1.value.count }
        
        if sortedProducts.isEmpty {
            output += "❌ No product browse engagement found for this individual\n"
            return output
        }
        
        // Format output
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        for (productName, events) in sortedProducts {
            let emoji = productName.lowercased() == "pizza" ? "🍕" : productName.lowercased() == "sushi" ? "🍣" : "📦"
            output += "─────────────────────────────────────────\n"
            output += "\(emoji) \(productName.uppercased()) (\(events.count) clicks)\n"
            output += "─────────────────────────────────────────\n"
            
            // Sort events by date (oldest first)
            let sortedEvents = events.sorted { $0.date < $1.date }
            
            for (index, event) in sortedEvents.enumerated() {
                let dateStr = dateFormatter.string(from: event.date)
                let isLatest = index == sortedEvents.count - 1
                output += "\n├─ Event \(index + 1)\(isLatest ? " ⭐ LATEST" : "")\n"
                output += "│  ├─ Date: \(dateStr) UTC\n"
                output += "│  └─ ID: \(event.id.prefix(8))...\n"
            }
            output += "\n"
        }
        
        // Summary
        output += "\n═══════════════════════════════════════════\n"
        output += "📈 SUMMARY\n"
        output += "═══════════════════════════════════════════\n\n"
        
        let totalClicks = sortedProducts.reduce(0) { $0 + $1.value.count }
        output += "Total Products: \(sortedProducts.count)\n"
        output += "Total Clicks: \(totalClicks)\n\n"
        
        for (productName, events) in sortedProducts {
            let sortedEvents = events.sorted { $0.date < $1.date }
            let firstDate = dateFormatter.string(from: sortedEvents.first!.date)
            let lastDate = dateFormatter.string(from: sortedEvents.last!.date)
            output += "• \(productName): \(events.count) clicks\n"
            output += "  First: \(firstDate)\n"
            output += "  Last: \(lastDate)\n\n"
        }
        
        return output
    }
}

// MARK: - Personalized Category Row

struct PersonalizedCategoryRow: View {
    let category: PersonalizedFoodCategory
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji Icon
            Text(category.emoji)
                .font(.system(size: 32))
                .frame(width: 50, height: 50)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(category.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let clickCount = category.clickCount, clickCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 10))
                        Text("\(clickCount) clicks on website")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.purple)
                    .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Score indicator
            if let score = category.score {
                VStack(spacing: 2) {
                    Text("\(Int(score * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Text("match")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Personalized Content Row

struct PersonalizedContentRow: View {
    let item: PersonalizedContentItem
    
    var body: some View {
        Group {
            if let urlString = item.actionUrl,
               let url = URL(string: urlString) {
                // Clickable version with link
                Link(destination: url) {
                    contentView
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Non-clickable version
                contentView
            }
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if item.actionUrl != nil {
                    HStack(spacing: 4) {
                        Text("Visit")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = item.description {
                Text(description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Show URL if available
            if let urlString = item.actionUrl {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    Text(urlString)
                        .font(.system(size: 10, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundColor(.purple)
                .padding(.top, 4)
            }
            
            // Metadata badges
            if !item.metadata.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(item.metadata.keys.prefix(2)), id: \.self) { key in
                        if let value = item.metadata[key], key != "decisionId" {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 8))
                                Text("\(key): \(value)")
                                    .font(.system(size: 10, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.pink.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
