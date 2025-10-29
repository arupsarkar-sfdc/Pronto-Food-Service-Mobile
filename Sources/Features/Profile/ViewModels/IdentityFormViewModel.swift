//
//  IdentityFormViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for identity form to collect user information and transition to known profile
//

import Foundation
import Combine

@MainActor
final class IdentityFormViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Required fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    
    // Optional fields
    @Published var phone: String = ""
    @Published var addressLine: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var postalCode: String = ""
    @Published var country: String = ""
    
    // UI State
    @Published var isSubmitting: Bool = false
    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isSubmitted: Bool = false
    
    // MARK: - Services
    
    private let profileService = ProfileDataService.shared
    private let loggingService = DataCloudLoggingService.shared
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Submit
    
    /// Submit the identity form and transition user to known profile
    func submitIdentity() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields with valid information."
            showingError = true
            return
        }
        
        isSubmitting = true
        
        // Clean up input
        let cleanFirstName = firstName.trimmingCharacters(in: .whitespaces)
        let cleanLastName = lastName.trimmingCharacters(in: .whitespaces)
        let cleanEmail = email.trimmingCharacters(in: .whitespaces)
        
        // Log identity submission
        loggingService.debug("Submitting identity form")
        loggingService.debug("  First Name: \(cleanFirstName)")
        loggingService.debug("  Last Name: \(cleanLastName)")
        loggingService.debug("  Email: \(cleanEmail)")
        
        // Prepare optional fields (clean and convert to optional strings)
        let cleanPhone = phone.trimmingCharacters(in: .whitespaces)
        let cleanAddress = addressLine.trimmingCharacters(in: .whitespaces)
        let cleanCity = city.trimmingCharacters(in: .whitespaces)
        let cleanState = state.trimmingCharacters(in: .whitespaces)
        let cleanPostal = postalCode.trimmingCharacters(in: .whitespaces)
        let cleanCountry = country.trimmingCharacters(in: .whitespaces)
        
        // Set known profile with ALL fields in a single call
        profileService.setKnownProfile(
            firstName: cleanFirstName,
            lastName: cleanLastName,
            email: cleanEmail,
            phoneNumber: cleanPhone.isEmpty ? nil : cleanPhone,
            addressLine1: cleanAddress.isEmpty ? nil : cleanAddress,
            city: cleanCity.isEmpty ? nil : cleanCity,
            state: cleanState.isEmpty ? nil : cleanState,
            postalCode: cleanPostal.isEmpty ? nil : cleanPostal,
            country: cleanCountry.isEmpty ? nil : cleanCountry
        )
        
        // Mark as submitted
        isSubmitting = false
        isSubmitted = true
        
        loggingService.success("Identity form submitted successfully")
        loggingService.debug("  User is now a KNOWN profile (isAnonymous = 0)")
    }
    
    // MARK: - Private Methods
    
    /// Check if any optional fields are filled
    private var hasOptionalFields: Bool {
        !phone.trimmingCharacters(in: .whitespaces).isEmpty ||
        !addressLine.trimmingCharacters(in: .whitespaces).isEmpty ||
        !city.trimmingCharacters(in: .whitespaces).isEmpty ||
        !state.trimmingCharacters(in: .whitespaces).isEmpty ||
        !postalCode.trimmingCharacters(in: .whitespaces).isEmpty ||
        !country.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    /// Update contact information with optional fields
    private func updateContactInformation() {
        let cleanPhone = phone.trimmingCharacters(in: .whitespaces)
        let hasAddress = !addressLine.trimmingCharacters(in: .whitespaces).isEmpty ||
                        !city.trimmingCharacters(in: .whitespaces).isEmpty
        
        var address: Address?
        if hasAddress {
            address = Address(
                line1: addressLine.trimmingCharacters(in: .whitespaces),
                city: city.trimmingCharacters(in: .whitespaces),
                state: state.trimmingCharacters(in: .whitespaces),
                postalCode: postalCode.trimmingCharacters(in: .whitespaces),
                country: country.trimmingCharacters(in: .whitespaces)
            )
        }
        
        profileService.updateContactInformation(
            phone: cleanPhone.isEmpty ? nil : cleanPhone,
            address: address
        )
        
        loggingService.debug("Contact information updated")
        if !cleanPhone.isEmpty {
            loggingService.debug("  Phone: \(cleanPhone)")
        }
        if let address = address {
            loggingService.debug("  Address: \(address.line1), \(address.city), \(address.state) \(address.postalCode)")
        }
    }
    
    /// Reset the form
    func resetForm() {
        firstName = ""
        lastName = ""
        email = ""
        phone = ""
        addressLine = ""
        city = ""
        state = ""
        postalCode = ""
        country = ""
        isSubmitted = false
        showingError = false
        errorMessage = ""
    }
}

