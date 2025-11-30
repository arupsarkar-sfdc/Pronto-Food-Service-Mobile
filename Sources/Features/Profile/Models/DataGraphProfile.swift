//
//  DataGraphProfile.swift
//  ProntoFoodDeliveryApp
//
//  Model for parsed Data Graph API response
//

import Foundation

/// Parsed and structured data from Data Cloud Data Graph API
public struct DataGraphProfile {
    // Identity
    public let unifiedRecordId: String
    public let firstName: String
    public let lastName: String
    public let isAnonymous: Bool
    public let email: String?
    
    // Source Systems
    public let sourceRecordIds: [SourceRecord]
    
    // Engagement
    public let productBrowseCount: Int
    public let recentProducts: [String]
    
    // Metadata
    public let createdDate: String?
    
    public struct SourceRecord {
        public let id: String
        public let dataSource: String
        
        public init(id: String, dataSource: String) {
            self.id = id
            self.dataSource = dataSource
        }
    }
    
    public init(
        unifiedRecordId: String,
        firstName: String,
        lastName: String,
        isAnonymous: Bool,
        email: String?,
        sourceRecordIds: [SourceRecord],
        productBrowseCount: Int,
        recentProducts: [String],
        createdDate: String?
    ) {
        self.unifiedRecordId = unifiedRecordId
        self.firstName = firstName
        self.lastName = lastName
        self.isAnonymous = isAnonymous
        self.email = email
        self.sourceRecordIds = sourceRecordIds
        self.productBrowseCount = productBrowseCount
        self.recentProducts = recentProducts
        self.createdDate = createdDate
    }
    
    /// Parse from Data Graph API response
    public static func parse(from response: [String: Any]) -> DataGraphProfile? {
        // Extract data array
        guard let dataArray = response["data"] as? [[String: Any]],
              let firstItem = dataArray.first,
              let jsonBlobString = firstItem["json_blob__c"] as? String,
              let jsonData = jsonBlobString.data(using: .utf8),
              let jsonBlob = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        // Extract unified profile info
        let unifiedRecordId = jsonBlob["ssot__Id__c"] as? String ?? ""
        let firstName = jsonBlob["ssot__FirstName__c"] as? String ?? ""
        let lastName = jsonBlob["ssot__LastName__c"] as? String ?? ""
        let isAnonymous = (jsonBlob["ssot__IsAnonymous__c"] as? String) == "1"
        let createdDate = jsonBlob["ssot__CreatedDate__c"] as? String
        
        // Extract email
        var email: String?
        if let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]],
           let firstLink = unifiedLinks.first,
           let individuals = firstLink["ssot__Individual__dlm"] as? [[String: Any]],
           let firstIndividual = individuals.first,
           let contactPoints = firstIndividual["ssot__ContactPointEmail__dlm"] as? [[String: Any]],
           let firstEmail = contactPoints.first {
            email = firstEmail["ssot__EmailAddress__c"] as? String
        }
        
        // Extract source records
        var sourceRecords: [SourceRecord] = []
        if let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]] {
            for link in unifiedLinks {
                if let sourceId = link["SourceRecordId__c"] as? String,
                   let individuals = link["ssot__Individual__dlm"] as? [[String: Any]],
                   let individual = individuals.first,
                   let dataSourceId = individual["ssot__DataSourceId__c"] as? String {
                    sourceRecords.append(SourceRecord(id: sourceId, dataSource: dataSourceId))
                }
            }
        }
        
        // Extract product browse engagement
        var productBrowseCount = 0
        var recentProducts: [String] = []
        if let unifiedLinks = jsonBlob["UnifiedLinkssotIndividualI1__dlm"] as? [[String: Any]],
           let firstLink = unifiedLinks.first,
           let individuals = firstLink["ssot__Individual__dlm"] as? [[String: Any]],
           let firstIndividual = individuals.first,
           let engagements = firstIndividual["ssot__ProductBrowseEngagement__dlm"] as? [[String: Any]] {
            productBrowseCount = engagements.count
            
            // Get recent 3 products
            recentProducts = engagements.prefix(3).compactMap { engagement in
                engagement["ssot__ProductId__c"] as? String
            }
        }
        
        return DataGraphProfile(
            unifiedRecordId: unifiedRecordId,
            firstName: firstName,
            lastName: lastName,
            isAnonymous: isAnonymous,
            email: email,
            sourceRecordIds: sourceRecords,
            productBrowseCount: productBrowseCount,
            recentProducts: recentProducts,
            createdDate: createdDate
        )
    }
}

