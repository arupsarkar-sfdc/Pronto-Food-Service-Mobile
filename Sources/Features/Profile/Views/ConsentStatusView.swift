//
//  ConsentStatusView.swift
//  ProntoFoodDeliveryApp
//
//  Displays current consent status with option to change
//

import SwiftUI

struct ConsentStatusView: View {
    @ObservedObject var consentService = ConsentService.shared
    let onManageConsentTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Collection Preferences")
                .font(.headline)
            
            if consentService.consentStatus != .notSet {
                consentStatusCard
            } else {
                noConsentCard
            }
        }
    }
    
    private var consentStatusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: currentConsentIcon)
                .font(.title2)
                .foregroundColor(currentConsentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(currentConsentTitle)
                    .font(.headline)
                    .foregroundColor(currentConsentColor)
                
                Text(currentConsentSubtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Change") {
                onManageConsentTapped()
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .padding()
        .background(currentConsentColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(currentConsentColor, lineWidth: 1)
        )
    }
    
    private var noConsentCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Consent Not Provided")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Please set your data collection preferences")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button("Set Preferences") {
                onManageConsentTapped()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    private var currentConsentIcon: String {
        switch consentService.consentStatus {
        case .optIn:
            return "checkmark.shield.fill"
        case .optOut:
            return "xmark.shield.fill"
        case .notSet:
            return "questionmark.circle.fill"
        }
    }
    
    private var currentConsentColor: Color {
        switch consentService.consentStatus {
        case .optIn:
            return .green
        case .optOut:
            return .red
        case .notSet:
            return .orange
        }
    }
    
    private var currentConsentTitle: String {
        switch consentService.consentStatus {
        case .optIn:
            return "Data Collection Enabled"
        case .optOut:
            return "Data Collection Disabled"
        case .notSet:
            return "Consent Not Set"
        }
    }
    
    private var currentConsentSubtitle: String {
        switch consentService.consentStatus {
        case .optIn:
            return "You opted in to data tracking"
        case .optOut:
            return "You opted out of data tracking"
        case .notSet:
            return "Set your preference"
        }
    }
}

#Preview {
    ConsentStatusView {
        print("Manage consent tapped")
    }
    .padding()
}

