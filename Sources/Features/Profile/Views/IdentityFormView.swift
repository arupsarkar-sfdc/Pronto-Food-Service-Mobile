//
//  IdentityFormView.swift
//  ProntoFoodDeliveryApp
//
//  Modal view for collecting user identity information
//  Transitions user from anonymous to known profile (isAnonymous = 0)
//

import SwiftUI

struct IdentityFormView: View {
    
    @StateObject private var viewModel = IdentityFormViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Required Fields Section
                    requiredFieldsSection
                    
                    // Optional Fields Section
                    optionalFieldsSection
                    
                    // Submit Button
                    submitButton
                }
                .padding()
            }
            .navigationTitle("Your Information")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 15))
                    .tint(.red)
                }
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onChange(of: viewModel.isSubmitted) { isSubmitted in
                if isSubmitted {
                    // Dismiss modal after successful submission
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Help Us Personalize Your Experience")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Share your information to get personalized recommendations and offers.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Required Fields Section
    
    private var requiredFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Required Information", icon: "asterisk.circle.fill")
            
            // First Name
            VStack(alignment: .leading, spacing: 4) {
                Text("First Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("John", text: $viewModel.firstName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                    .autocorrectionDisabled()
                    .glassEffect()
                    .tint(.purple)
            }
            
            // Last Name
            VStack(alignment: .leading, spacing: 4) {
                Text("Last Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Doe", text: $viewModel.lastName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.familyName)
                    .autocapitalization(.words)
                    .glassEffect()
            }
            
            // Email
            VStack(alignment: .leading, spacing: 4) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("john.doe@example.com", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .glassEffect()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Optional Fields Section
    
    private var optionalFieldsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Optional Information", icon: "info.circle.fill")
            
            // Phone
            VStack(alignment: .leading, spacing: 4) {
                Text("Phone Number")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("+1 (555) 123-4567", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .glassEffect()
            }
            
            Divider()
            
            Text("Address")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // Address Line
            VStack(alignment: .leading, spacing: 4) {
                Text("Street Address")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("123 Main Street", text: $viewModel.addressLine)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.streetAddressLine1)
                    .glassEffect()
            }
            
            // City
            VStack(alignment: .leading, spacing: 4) {
                Text("City")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("San Francisco", text: $viewModel.city)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.addressCity)
                    .glassEffect()
            }
            
            // State & Postal Code
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("State")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("CA", text: $viewModel.state)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.addressState)
                        .autocapitalization(.allCharacters)
                        .glassEffect()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Postal Code")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("94105", text: $viewModel.postalCode)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.postalCode)
                        .keyboardType(.numberPad)
                        .glassEffect()
                }
            }
            
            // Country
            VStack(alignment: .leading, spacing: 4) {
                Text("Country")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("USA", text: $viewModel.country)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.countryName)
                    .glassEffect()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: {
            viewModel.submitIdentity()
        }) {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Submit")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
//            .background(viewModel.isFormValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        .buttonStyle(.glassProminent)
        .tint(.blue)
        
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    IdentityFormView()
}

