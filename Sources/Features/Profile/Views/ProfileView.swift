//
//  ProfileView.swift
//  ProntoFoodDeliveryApp
//
//  Profile screen with identity management and status widgets
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profileService = ProfileDataService.shared
    @ObservedObject var consentService = ConsentService.shared
    @State private var showingIdentityForm = false
    @State private var showingConsentSheet = false
    @State private var showingSettings = false
    @State private var showingDataGraph = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Data Cloud Status Widget
                    dataCloudStatusWidget
                    
                    // Identity Section
                    if profileService.isKnownUser {
                        knownUserSection
                    } else {
                        anonymousUserSection
                    }
                    
                    // Colorful Status Widgets
                    VStack(spacing: 16) {
                        // Data Collection Widget
                        ConsentStatusView {
                            showingConsentSheet = true
                        }
                        
                        // Location Tracking Widget
                        LocationStatusView()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .toolbar {
                // User Data Graph Icon (top-left, only when known user)
                if profileService.isKnownUser {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingDataGraph = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                // Settings Icon (top-right)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingIdentityForm) {
                IdentityFormView()
            }
            .sheet(isPresented: $showingConsentSheet) {
                ConsentView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingDataGraph) {
                UserDataGraphView()
            }
        }
    }
    
    // MARK: - Data Cloud Status Widget
    
    private var dataCloudStatusWidget: some View {
        HStack(spacing: 12) {
            if CredentialsManager.shared.hasConfiguredCredentials {
                Image(systemName: "cloud.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Data Cloud Enabled")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Events tracking to Salesforce")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Data Cloud Not Configured")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Tap settings to configure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(CredentialsManager.shared.hasConfiguredCredentials ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(CredentialsManager.shared.hasConfiguredCredentials ? Color.blue.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .onTapGesture {
            showingSettings = true
        }
    }
    
    // MARK: - Anonymous User Section
    
    private var anonymousUserSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anonymous User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You're browsing anonymously")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                showingIdentityForm = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.headline)
                    Text("Share Your Information")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Text("Get personalized recommendations by sharing your information")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Known User Section
    
    private var knownUserSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Greeting with first name
                    Text("Hello, \(profileService.firstName)!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // "Known User" badge
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Text("Known User")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.gradient)
                    )
                    
                    Text("You're enjoying personalized experiences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            
            Button(action: {
                // Logout - reset to anonymous
                profileService.logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle")
                        .font(.headline)
                    Text("Reset to Anonymous")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
            
            Text("Reset to anonymous mode to stop personalization")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
