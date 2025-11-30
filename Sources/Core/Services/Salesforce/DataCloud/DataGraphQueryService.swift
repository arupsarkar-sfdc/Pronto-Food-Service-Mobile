//
//  DataGraphQueryService.swift
//  ProntoFoodDeliveryApp
//
//  Service for querying Salesforce Data Graph API
//  Reference: https://developer.salesforce.com/docs/data/data-cloud-query-guide/references/data-cloud-query-api-reference/c360a-api-v1-data-graphs-lookup.html
//

import Foundation
import Combine

// MARK: - Data Graph Query Service

public final class DataGraphQueryService {
    
    // MARK: - Singleton
    
    public static let shared = DataGraphQueryService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let enableLogging = true
    private let tokenService = TokenService.shared
    
    // MARK: - Query Data Graph
    
    /// Query Data Graph with lookup keys
    /// - Parameters:
    ///   - dataGraphName: Name of the data graph (e.g., "C360_Contact_RT")
    ///   - dmoName: Data Model Object name (e.g., "UnifiedLinkssotIndividualI1__dlm")
    ///   - fieldName: Field name to query (e.g., "UnifiedRecordId__c")
    ///   - value: Value to lookup (e.g., unified ID)
    ///   - live: If true, retrieves real-time data; if false, retrieves precalculated data (default: true)
    /// - Returns: Data Graph response dictionary
    public func queryDataGraph(
        dataGraphName: String,
        dmoName: String,
        fieldName: String,
        value: String,
        live: Bool = true
    ) async throws -> [String: Any] {
        
        if enableLogging {
            print("═══════════════════════════════════════════")
            print("📊 DataGraphQueryService: Starting query")
            print("   Data Graph: \(dataGraphName)")
            print("   DMO: \(dmoName)")
            print("   Field: \(fieldName)")
            print("   Value: \(value)")
        }
        
        // Get token
        let token = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            tokenService.fetchAccessToken()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { token in
                        continuation.resume(returning: token)
                    }
                )
                .store(in: &cancellables)
        }
        
        if enableLogging {
            print("✅ Token retrieved")
            print("   Token: \(token.prefix(20))...")
        }
        
        // Get Data Cloud endpoint
        guard let endpoint = CredentialsManager.shared.endpoint,
              !endpoint.isEmpty else {
            throw DataGraphError.endpointNotConfigured
        }
        
        // Build URL - following the working pattern from UserDataGraphViewModel
        let lookupKeys = "\(dmoName).\(fieldName)=\(value)"
        let baseUrl = "https://\(endpoint)/api/v1/dataGraph/\(dataGraphName)"
        let urlString = "\(baseUrl)?lookupKeys=[\(lookupKeys)]"
        
        if enableLogging {
            print("🔗 Request URL:")
            print("   \(urlString)")
            print("🔗 Lookup Keys: \(lookupKeys)")
        }
        
        guard let url = URL(string: urlString) else {
            throw DataGraphError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if enableLogging {
            print("📤 Sending request...")
        }
        
        // Make API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataGraphError.invalidResponse
        }
        
        if enableLogging {
            print("📥 Response received")
            print("   Status Code: \(httpResponse.statusCode)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw DataGraphError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Parse JSON
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        if enableLogging {
            print("✅ Data Graph response parsed")
            if let dataArray = json["data"] as? [[String: Any]] {
                print("   Records: \(dataArray.count)")
                print("   📋 Response data:")
                print("   \(json)")
            }
            print("═══════════════════════════════════════════")
        }
        
        return json
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Data Graph Errors

public enum DataGraphError: LocalizedError {
    case endpointNotConfigured
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case tokenError
    
    public var errorDescription: String? {
        switch self {
        case .endpointNotConfigured:
            return "Data Cloud endpoint not configured"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .tokenError:
            return "Failed to retrieve token"
        }
    }
}

