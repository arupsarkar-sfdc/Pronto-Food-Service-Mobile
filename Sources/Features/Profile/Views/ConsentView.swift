//
//  ConsentView.swift
//  ProntoFoodDeliveryApp
//
//  Modal view for managing user data collection consent
//

import SwiftUI

struct ConsentView: View {
    @AppStorage("hasConsented") private var hasConsented: Bool = false
    @AppStorage("userConsentStatus") private var userConsentStatus: String = "notSet"
    @Environment(\.dismiss) private var dismiss
    
    private func setConsentWithDelay(_ status: ConsentStatus) {
        userConsentStatus = status == .optIn ? "optIn" : "optOut"
        hasConsented = true
        dismiss()
        
        // Wait for SDK to be operational, then set consent
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if DataCloudService.shared.isCdpModuleOperational() {
                DataCloudService.shared.setConsent(status)
                print("✅ Consent set to: \(status)")
            } else {
                // Try again after another delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    DataCloudService.shared.setConsent(status)
                    print("✅ Consent set (delayed) to: \(status)")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                
                // Title
                Text("Data Collection Consent")
                    .font(.title)
                    .bold()
                
                // Description
                Text("We collect behavioral and profile data to personalize your experience and improve our services. You can change this preference anytime in settings.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // What we collect
                    DisclosureGroup("What data do we collect?") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("App interactions and screen views", systemImage: "hand.tap")
                            Label("Cart and order events", systemImage: "cart")
                            Label("Product views and favorites", systemImage: "heart")
                            Label("Location data (if enabled)", systemImage: "location")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        setConsentWithDelay(.optIn)
                    }) {
                        Text("Allow Data Collection")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        setConsentWithDelay(.optOut)
                    }) {
                        Text("Decline")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ConsentView()
}

