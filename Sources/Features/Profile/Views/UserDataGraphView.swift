//
//  UserDataGraphView.swift
//  ProntoFoodDeliveryApp
//
//  Modal view to display user's Data Cloud data graph
//  Shows unified profile, identity resolution, and engagement insights
//

import SwiftUI

struct UserDataGraphView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileService = ProfileDataService.shared
    @StateObject private var viewModel = UserDataGraphViewModel()
    @State private var sourceRecordId: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Source Record ID Input Widget
                    sourceRecordIdInputWidget
                    
                    // API Data Graph Response
                    if viewModel.isFetchingDataGraph {
                        dataGraphLoadingCard
                    } else if let error = viewModel.errorMessage {
                        dataGraphErrorCard(error: error)
                    } else if let dataGraph = viewModel.dataGraphResponse {
                        dataGraphResponseCard(data: dataGraph)
                    }
                    
                    // Data Graph Sections
                    VStack(spacing: 16) {
                        // Identity Resolution with Unified ID
                        identityResolutionSection
                        
                        // Engagement Insights with Product Views
                        engagementInsightsSection
                        
                        dataGraphSection(
                            icon: "location.fill",
                            title: "Location & Context",
                            description: "Geographic data and behavioral patterns",
                            color: .orange
                        )
                        
                        dataGraphSection(
                            icon: "hand.raised.fill",
                            title: "Consent & Preferences",
                            description: "Privacy settings and communication preferences",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Center Badge - Shows token preview
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "key.fill")
                                .font(.caption)
                        }
                        
                        Text(viewModel.isLoading ? "Loading..." : viewModel.tokenPreview)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                
                // Done Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Fetch token when view appears
                viewModel.fetchToken()
                // Also fetch data graph
                viewModel.fetchDataGraph()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // User Avatar with Gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // User Name
            Text(profileService.firstName.isEmpty ? "User" : profileService.firstName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            // User Email
            if !profileService.email.isEmpty {
                Text(profileService.email)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            // Data Cloud Badge
            HStack(spacing: 6) {
                Image(systemName: "cloud.fill")
                    .font(.caption)
                Text("Data Cloud Connected")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .padding()
    }
    
    // MARK: - Source Record ID Input Widget
    
    private var sourceRecordIdInputWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Fetch Data Graph")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            HStack(spacing: 12) {
                // Text Input
                TextField("Enter Source Record ID (email)", text: $sourceRecordId)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                // Fetch Button (Transparent style)
                Button(action: {
                    if !sourceRecordId.isEmpty {
                        viewModel.performDataGraphFetch(sourceRecordId: sourceRecordId)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Fetch")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                            .background(Color.clear)
                    )
                }
                .disabled(sourceRecordId.isEmpty)
                .opacity(sourceRecordId.isEmpty ? 0.5 : 1.0)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Engagement Insights Section
    
    private var engagementInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Engagement Insights")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Product views, cart activities, and interactions")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Engagement Data (if available)
            if let profile = viewModel.parsedProfile {
                Divider()
                    .padding(.vertical, 4)
                
                // Product Views Count
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "eye.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.pink)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Product Views")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(profile.productBrowseCount) items")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                
                // Recent Products
                if !profile.recentProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.indigo)
                            Text("Recent Products")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                        
                        VStack(spacing: 8) {
                            ForEach(profile.recentProducts, id: \.self) { productId in
                                HStack(spacing: 12) {
                                    Image(systemName: "cube.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.indigo)
                                        .frame(width: 20)
                                    
                                    Text(productId)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .glassEffect()
    }
    
    // MARK: - Identity Resolution Section
    
    private var identityResolutionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Identity Resolution")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Unified profile across devices and channels")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Unified ID Capsule (if available)
            if let profile = viewModel.parsedProfile {
                HStack(spacing: 8) {
                    Image(systemName: "link.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text(profile.unifiedRecordId)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .glassEffect()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .glassEffect()
    }
    
    // MARK: - Data Graph Section
    
    private func dataGraphSection(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .glassEffect()
    }
    
    // MARK: - API Response Cards
    
    private var dataGraphLoadingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Fetching Data Graph...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func dataGraphErrorCard(error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Error Loading Data Graph")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
            }
            
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.fetchDataGraph()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange, lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func dataGraphResponseCard(data: [String: Any]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "server.rack")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Data Graph Response")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                // Refresh button
                Button(action: {
                    viewModel.fetchDataGraph()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            // Display parsed profile data
            if let profile = viewModel.parsedProfile {
                VStack(alignment: .leading, spacing: 16) {
                    // Identity Summary
                    profileSummaryRow(
                        icon: "person.circle.fill",
                        label: "Name",
                        value: "\(profile.firstName) \(profile.lastName)",
                        color: .blue
                    )
                    
                    if let email = profile.email {
                        profileSummaryRow(
                            icon: "envelope.circle.fill",
                            label: "Email",
                            value: email,
                            color: .green
                        )
                    }
                    
                    profileSummaryRow(
                        icon: "link.circle.fill",
                        label: "Unified ID",
                        value: profile.unifiedRecordId,
                        color: .purple
                    )
                    
                    profileSummaryRow(
                        icon: "server.rack",
                        label: "Source Systems",
                        value: "\(profile.sourceRecordIds.count) connected",
                        color: .orange
                    )
                    
                    if let createdDate = profile.createdDate {
                        profileSummaryRow(
                            icon: "calendar.circle.fill",
                            label: "Created",
                            value: createdDate,
                            color: .gray
                        )
                    }
                }
            } else {
                // Fallback to raw JSON if parsing failed
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(data.keys.sorted()), id: \.self) { key in
                            HStack(alignment: .top, spacing: 12) {
                                Text(key)
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.blue)
                                
                                Text(":")
                                    .foregroundColor(.secondary)
                                
                                Text(formatValue(data[key]))
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .glassEffect()
    }
    
    // MARK: - Profile Summary Row
    
    private func profileSummaryRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatValue(_ value: Any?) -> String {
        guard let value = value else {
            return "null"
        }
        
        if let string = value as? String {
            return "\"\(string)\""
        } else if let number = value as? NSNumber {
            return "\(number)"
        } else if let array = value as? [Any] {
            return "[\(array.count) items]"
        } else if let dict = value as? [String: Any] {
            return "{\(dict.count) fields}"
        } else {
            return String(describing: value)
        }
    }
    
}

// MARK: - Preview

#Preview {
    UserDataGraphView()
}

