//
//  SettingsView.swift
//  ProntoFoodDeliveryApp
//
//  Settings modal for configuring Salesforce Data Cloud credentials
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var appId: String = ""
    @State private var endpoint: String = ""
    @State private var tokenEndpoint: String = ""
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Salesforce Data Cloud Settings", systemImage: "cloud.fill")
                            .font(.headline)
                        
                        Text("Configure your org's credentials to enable event tracking")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Credentials") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("App ID")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter App ID from Mobile Connector", text: $appId)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Endpoint")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("your-org.marketing.salesforce.com", text: $endpoint)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }
                }
                
                Section {
                    if CredentialsManager.shared.hasConfiguredCredentials {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Credentials Configured")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text("Current App ID: \(maskAppId(CredentialsManager.shared.appId ?? ""))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                            Text("No credentials configured")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Data Graph Token Service") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token Endpoint URL")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("https://your-app.herokuapp.com/get-token", text: $tokenEndpoint)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }
                    
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundStyle(.green)
                        Text("Used for fetching JWT tokens to access Data Graph API")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How to get credentials:", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            StepView(number: 1, text: "Log into Salesforce Data Cloud")
                            StepView(number: 2, text: "Go to Settings → Mobile Apps")
                            StepView(number: 3, text: "Create or select Mobile Connector")
                            StepView(number: 4, text: "Copy App ID and Endpoint")
                            StepView(number: 5, text: "Paste values above and save")
                        }
                        .font(.caption)
                    }
                    .listRowBackground(Color.blue.opacity(0.05))
                }
                
                Section {
                    Button(action: clearCredentials) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Credentials")
                        }
                        .foregroundStyle(.red)
                    }
                    .disabled(!CredentialsManager.shared.hasConfiguredCredentials)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCredentials()
                    }
                    .fontWeight(.semibold)
                    .disabled(appId.isEmpty || endpoint.isEmpty)
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Credentials saved successfully. Please restart the app to apply changes.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadCurrentCredentials()
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadCurrentCredentials() {
        appId = CredentialsManager.shared.appId ?? ""
        endpoint = CredentialsManager.shared.endpoint ?? ""
        tokenEndpoint = UserDefaults.standard.string(forKey: "com.pronto.tokenEndpoint") ?? ""
    }
    
    private func saveCredentials() {
        let validation = CredentialsManager.shared.validateCredentials(
            appId: appId,
            endpoint: endpoint
        )
        
        if validation.isValid {
            CredentialsManager.shared.saveCredentials(
                appId: appId,
                endpoint: endpoint
            )
            
            // Save token endpoint
            if !tokenEndpoint.isEmpty {
                TokenService.shared.configure(endpoint: tokenEndpoint)
            }
            
            showSuccessAlert = true
        } else {
            errorMessage = validation.error ?? "Invalid credentials"
            showErrorAlert = true
        }
    }
    
    private func clearCredentials() {
        CredentialsManager.shared.clearCredentials()
        TokenService.shared.clearCache()
        appId = ""
        endpoint = ""
        tokenEndpoint = ""
    }
    
    private func maskAppId(_ id: String) -> String {
        guard id.count > 8 else { return id }
        let prefix = id.prefix(4)
        let suffix = id.suffix(4)
        return "\(prefix)••••\(suffix)"
    }
}

// MARK: - Step View

struct StepView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

