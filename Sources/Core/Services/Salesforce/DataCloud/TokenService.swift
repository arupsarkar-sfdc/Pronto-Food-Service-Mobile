//
//  TokenService.swift
//  ProntoFoodDeliveryApp
//
//  Service for retrieving JWT tokens to access Salesforce Data Cloud APIs
//  Handles token caching, expiration, and automatic refresh
//

import Foundation
import Combine

// MARK: - Token Response Models

/// Response structure from token endpoint
public struct TokenResponse: Codable {
    public let token: Token
    
    public struct Token: Codable {
        public let accessToken: String
        public let expiresIn: Int
        public let instanceUrl: String
        public let issuedTokenType: String
        public let tokenType: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case instanceUrl = "instance_url"
            case issuedTokenType = "issued_token_type"
            case tokenType = "token_type"
        }
    }
}

// MARK: - Cached Token

/// Internal structure for caching tokens with expiration
private struct CachedToken {
    let token: TokenResponse.Token
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() >= expirationDate
    }
}

// MARK: - Token Service

/// Service for managing JWT token retrieval and caching for Data Cloud API access
public final class TokenService {
    
    // MARK: - Singleton
    
    public static let shared = TokenService()
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Properties
    
    /// Cached token with expiration tracking
    private var cachedToken: CachedToken?
    
    /// Token endpoint URL
    private var tokenEndpoint: String = ""
    
    /// Enable debug logging
    private var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// UserDefaults key for token endpoint
    private let tokenEndpointKey = "com.pronto.tokenEndpoint"
    
    // MARK: - Configuration
    
    /// Load token endpoint from UserDefaults or use default
    private func loadConfiguration() {
        tokenEndpoint = UserDefaults.standard.string(forKey: tokenEndpointKey) ?? ""
        
        if enableLogging && !tokenEndpoint.isEmpty {
            print("🔐 TokenService: Loaded endpoint configuration")
            print("   Endpoint: \(tokenEndpoint)")
        }
    }
    
    /// Configure token service with custom endpoint
    /// - Parameter endpoint: URL string for token retrieval endpoint
    public func configure(endpoint: String) {
        tokenEndpoint = endpoint
        UserDefaults.standard.set(endpoint, forKey: tokenEndpointKey)
        
        if enableLogging {
            print("🔐 TokenService: Configured with endpoint")
            print("   Endpoint: \(endpoint)")
        }
    }
    
    /// Check if token service is configured
    public var isConfigured: Bool {
        !tokenEndpoint.isEmpty
    }
    
    // MARK: - Token Retrieval
    
    /// Fetch access token (uses cache if valid, otherwise fetches new token)
    /// - Returns: Publisher that emits TokenResponse or error
    public func fetchToken() -> AnyPublisher<TokenResponse, Error> {
        // Check if we have a valid cached token
        if let cached = cachedToken, !cached.isExpired {
            if enableLogging {
                print("🔐 TokenService: Using cached token")
                print("   Expires: \(cached.expirationDate)")
            }
            
            let response = TokenResponse(token: cached.token)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Fetch new token
        return fetchNewToken()
    }
    
    /// Force fetch a new token (bypasses cache)
    /// - Returns: Publisher that emits TokenResponse or error
    public func fetchNewToken() -> AnyPublisher<TokenResponse, Error> {
        guard isConfigured else {
            if enableLogging {
                print("❌ TokenService: Not configured - cannot fetch token")
            }
            return Fail(error: TokenServiceError.notConfigured)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: tokenEndpoint) else {
            if enableLogging {
                print("❌ TokenService: Invalid endpoint URL")
            }
            return Fail(error: TokenServiceError.invalidEndpoint)
                .eraseToAnyPublisher()
        }
        
        if enableLogging {
            print("🔐 TokenService: Fetching new token")
            print("   Endpoint: \(tokenEndpoint)")
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TokenServiceError.invalidResponse
                }
                
                if self.enableLogging {
                    print("🔐 TokenService: Received response")
                    print("   Status Code: \(httpResponse.statusCode)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw TokenServiceError.httpError(statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .handleEvents(
                receiveOutput: { [weak self] response in
                    self?.cacheToken(response.token)
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        if self.enableLogging {
                            print("❌ TokenService: Failed to fetch token")
                            print("   Error: \(error.localizedDescription)")
                        }
                    }
                }
            )
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Token Caching
    
    /// Cache token with expiration
    /// - Parameter token: Token to cache
    private func cacheToken(_ token: TokenResponse.Token) {
        // Calculate expiration date (subtract 5 minutes as buffer)
        let bufferTime: TimeInterval = 300 // 5 minutes
        let expirationDate = Date().addingTimeInterval(TimeInterval(token.expiresIn) - bufferTime)
        
        cachedToken = CachedToken(token: token, expirationDate: expirationDate)
        
        if enableLogging {
            print("🔐 TokenService: Token cached")
            print("   Expires In: \(token.expiresIn)s")
            print("   Expiration Date: \(expirationDate)")
            print("   Instance URL: \(token.instanceUrl)")
        }
    }
    
    /// Clear cached token (forces next fetch to get new token)
    public func clearCache() {
        cachedToken = nil
        
        if enableLogging {
            print("🔐 TokenService: Cache cleared")
        }
    }
    
    /// Get cached token if valid
    /// - Returns: Cached token or nil if expired/not available
    public func getCachedToken() -> TokenResponse.Token? {
        guard let cached = cachedToken, !cached.isExpired else {
            return nil
        }
        return cached.token
    }
}

// MARK: - Token Service Errors

public enum TokenServiceError: LocalizedError {
    case notConfigured
    case invalidEndpoint
    case invalidResponse
    case httpError(statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Token service is not configured. Please set the endpoint URL."
        case .invalidEndpoint:
            return "Invalid token endpoint URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}

// MARK: - Convenience Extensions

extension TokenService {
    /// Fetch token and return just the access token string
    /// - Returns: Publisher that emits access token string or error
    public func fetchAccessToken() -> AnyPublisher<String, Error> {
        fetchToken()
            .map { $0.token.accessToken }
            .eraseToAnyPublisher()
    }
    
    /// Fetch token and return instance URL
    /// - Returns: Publisher that emits instance URL string or error
    public func fetchInstanceUrl() -> AnyPublisher<String, Error> {
        fetchToken()
            .map { $0.token.instanceUrl }
            .eraseToAnyPublisher()
    }
}

