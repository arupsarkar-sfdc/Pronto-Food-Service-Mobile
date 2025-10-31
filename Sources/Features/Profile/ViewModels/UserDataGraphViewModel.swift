//
//  UserDataGraphViewModel.swift
//  ProntoFoodDeliveryApp
//
//  ViewModel for User Data Graph view - handles token fetching and data graph API calls
//

import Foundation
import Combine

@MainActor
public final class UserDataGraphViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Access token for Data Cloud API
    @Published public var accessToken: String?
    
    /// Loading state
    @Published public var isLoading = false
    
    /// Error message
    @Published public var errorMessage: String?
    
    /// Instance URL from token response
    @Published public var instanceUrl: String?
    
    /// Data graph response (raw)
    @Published public var dataGraphResponse: [String: Any]?
    
    /// Parsed data graph profile
    @Published public var parsedProfile: DataGraphProfile?
    
    /// Is fetching data graph
    @Published public var isFetchingDataGraph = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Data Cloud endpoint (will be read from settings)
    private var dataCloudEndpoint: String {
        return CredentialsManager.shared.endpoint ?? ""
    }
    
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Computed Properties
    
    /// Last 8 characters of token for display
    public var tokenPreview: String {
        guard let token = accessToken else {
            return "••••••••"
        }
        
        if token.count >= 8 {
            let index = token.index(token.endIndex, offsetBy: -8)
            return String(token[index...])
        }
        
        return token
    }
    
    /// Check if token is available
    public var hasToken: Bool {
        accessToken != nil
    }
    
    // MARK: - Public Methods
    
    /// Fetch access token from TokenService
    public func fetchToken() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        if enableLogging {
            print("🔐 UserDataGraphViewModel: Fetching token")
        }
        
        TokenService.shared.fetchToken()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                        
                        if self.enableLogging {
                            print("❌ UserDataGraphViewModel: Token fetch failed")
                            print("   Error: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    
                    self.accessToken = response.token.accessToken
                    self.instanceUrl = response.token.instanceUrl
                    
                    if self.enableLogging {
                        print("✅ UserDataGraphViewModel: Token received")
                        print("   Token Preview: ...\(self.tokenPreview)")
                        print("   Instance URL: \(response.token.instanceUrl)")
                        print("   Expires In: \(response.token.expiresIn)s")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Fetch data graph from Data Cloud API
    public func fetchDataGraph() {
        // Get user email as sourceRecordId
        let userEmail = ProfileDataService.shared.email
        
        guard !userEmail.isEmpty else {
            errorMessage = "No user email found. Please set your profile first."
            if enableLogging {
                print("⚠️ UserDataGraphViewModel: No user email available")
            }
            return
        }
        
        // First ensure we have a token
        if accessToken == nil {
            fetchToken()
            // Wait for token, then fetch data graph
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.performDataGraphFetch(sourceRecordId: userEmail)
            }
        } else {
            performDataGraphFetch(sourceRecordId: userEmail)
        }
    }
    
    /// Perform the actual Data Graph API call
    public func performDataGraphFetch(sourceRecordId: String) {
        guard let token = accessToken else {
            errorMessage = "No token available"
            return
        }
        
        guard !dataCloudEndpoint.isEmpty else {
            errorMessage = "Data Cloud endpoint not configured"
            return
        }
        
        isFetchingDataGraph = true
        errorMessage = nil
        
        // Construct endpoint
        let endpoint = "https://\(dataCloudEndpoint)/api/v1/dataGraph/C360_Contact_RT"
        let lookupKeys = "UnifiedLinkssotIndividualI1__dlm.UnifiedRecordId__c=\(sourceRecordId)"
        let urlString = "\(endpoint)?lookupKeys=[\(lookupKeys)]"
        
        if enableLogging {
            print("📊 UserDataGraphViewModel: Fetching data graph")
            print("   Endpoint: \(endpoint)")
            print("   Lookup Keys: \(lookupKeys)")
            print("   Source Record ID: \(sourceRecordId)")
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isFetchingDataGraph = false
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Make API call
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isFetchingDataGraph = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    if self.enableLogging {
                        print("❌ UserDataGraphViewModel: Network error")
                        print("   Error: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    return
                }
                
                if self.enableLogging {
                    print("📊 UserDataGraphViewModel: Response received")
                    print("   Status Code: \(httpResponse.statusCode)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "HTTP error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                // Parse JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        self.dataGraphResponse = json
                        
                        // Parse into structured model
                        self.parsedProfile = DataGraphProfile.parse(from: json)
                        
                        if self.enableLogging {
                            print("✅ UserDataGraphViewModel: Data graph fetched successfully")
                            if let profile = self.parsedProfile {
                                print("   📊 Parsed Profile:")
                                print("      Unified ID: \(profile.unifiedRecordId)")
                                print("      Name: \(profile.firstName) \(profile.lastName)")
                                print("      Email: \(profile.email ?? "N/A")")
                                print("      Source Systems: \(profile.sourceRecordIds.count)")
                                print("      Product Views: \(profile.productBrowseCount)")
                            }
                        }
                    } else {
                        self.errorMessage = "Invalid JSON format"
                    }
                } catch {
                    self.errorMessage = "JSON parsing error: \(error.localizedDescription)"
                    if self.enableLogging {
                        print("❌ UserDataGraphViewModel: JSON parsing error")
                        print("   Error: \(error.localizedDescription)")
                    }
                }
            }
        }.resume()
    }
    
    /// Refresh token
    public func refreshToken() {
        if enableLogging {
            print("🔄 UserDataGraphViewModel: Refreshing token")
        }
        
        // Clear cache and fetch new token
        TokenService.shared.clearCache()
        fetchToken()
    }
}

