import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
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
                    Text("Pro Code Personalization")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    proCodePersonalizationCard
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Personalization")
        .navigationBarTitleDisplayMode(.large)
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
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 8)
            
            // Title & Description
            VStack(spacing: 8) {
                Text("Personalization SDK")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Advanced personalization using Salesforce's developer SDK with custom logic")
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
            .foregroundColor(.purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.15))
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
}
