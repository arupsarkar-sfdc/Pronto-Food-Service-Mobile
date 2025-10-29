//
//  ProfileEvents.swift
//  ProntoFoodDeliveryApp
//
//  Profile category event models for Data Cloud
//  Reference: https://developer.salesforce.com/docs/data/data-cloud-ref/guide/c360a-api-engagement-mobile-sdk-event-specifications.html
//

import Foundation

// MARK: - Identity Event

public struct IdentityEvent: DataCloudEvent {
    public var category: EventCategory = .profile
    public var eventType: String = "identity"
    
    // Required fields
    let isAnonymous: String
    
    // Optional fields
    let addressLine1: String?
    let addressLine2: String?
    let addressLine3: String?
    let addressLine4: String?
    let advertiserId: String?
    let channel: String?
    let city: String?
    let country: String?
    let deviceType: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let location: LocationData?
    let osName: String?
    let osVersion: String?
    let phoneNumber: String?
    let postalCode: String?
    let registrationId: String?
    let softwareApplicationName: String?
    let softwareApplicationVersion: String?
    let stateProvince: String?
    
    public init(
        isAnonymous: String,
        addressLine1: String? = nil,
        addressLine2: String? = nil,
        addressLine3: String? = nil,
        addressLine4: String? = nil,
        advertiserId: String? = nil,
        channel: String? = nil,
        city: String? = nil,
        country: String? = nil,
        deviceType: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        location: LocationData? = nil,
        osName: String? = nil,
        osVersion: String? = nil,
        phoneNumber: String? = nil,
        postalCode: String? = nil,
        registrationId: String? = nil,
        softwareApplicationName: String? = nil,
        softwareApplicationVersion: String? = nil,
        stateProvince: String? = nil
    ) {
        self.isAnonymous = isAnonymous
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.addressLine4 = addressLine4
        self.advertiserId = advertiserId
        self.channel = channel
        self.city = city
        self.country = country
        self.deviceType = deviceType
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.osName = osName
        self.osVersion = osVersion
        self.phoneNumber = phoneNumber
        self.postalCode = postalCode
        self.registrationId = registrationId
        self.softwareApplicationName = softwareApplicationName
        self.softwareApplicationVersion = softwareApplicationVersion
        self.stateProvince = stateProvince
    }
}

// MARK: - Contact Point Address Event

public struct ContactPointAddressEvent: DataCloudEvent {
    public let category: EventCategory = .profile
    public let eventType: String = "contactPointAddress"
    
    // Required fields
    let addressLine1: String
    let city: String
    let country: String
    let postalCode: String
    let stateProvince: String
    
    // Optional fields
    let addressLine2: String?
    let addressLine3: String?
    let addressLine4: String?
    let channel: String?
    let location: LocationData?
    
    public init(
        addressLine1: String,
        city: String,
        country: String,
        postalCode: String,
        stateProvince: String,
        addressLine2: String? = nil,
        addressLine3: String? = nil,
        addressLine4: String? = nil,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.addressLine1 = addressLine1
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.stateProvince = stateProvince
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.addressLine4 = addressLine4
        self.channel = channel
        self.location = location
    }
}

// MARK: - Contact Point Email Event

public struct ContactPointEmailEvent: DataCloudEvent {
    public let category: EventCategory = .profile
    public let eventType: String = "contactPointEmail"
    
    // Required fields
    let email: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    
    public init(
        email: String,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.email = email
        self.channel = channel
        self.location = location
    }
}

// MARK: - Contact Point Phone Event

public struct ContactPointPhoneEvent: DataCloudEvent {
    public let category: EventCategory = .profile
    public let eventType: String = "contactPointPhone"
    
    // Required fields
    let phoneNumber: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    
    public init(
        phoneNumber: String,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.phoneNumber = phoneNumber
        self.channel = channel
        self.location = location
    }
}

// MARK: - Party Identification Event

public struct PartyIdentificationEvent: DataCloudEvent {
    public let category: EventCategory = .profile
    public let eventType: String = "partyIdentification"
    
    // Required fields
    let idName: String
    let idType: String
    let userId: String
    
    // Optional fields
    let channel: String?
    let location: LocationData?
    
    enum CodingKeys: String, CodingKey {
        // Only include fields that should be sent as attributes
        // Exclude: category, eventType, channel (auto-assigned by SDK)
        case userId, location
        case idName = "IDName"
        case idType = "IDType"
    }
    
    public init(
        idName: String,
        idType: String,
        userId: String,
        channel: String? = nil,
        location: LocationData? = nil
    ) {
        self.idName = idName
        self.idType = idType
        self.userId = userId
        self.channel = channel
        self.location = location
    }
    
    // Manual Decodable implementation (though we don't decode these events)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.idName = try container.decode(String.self, forKey: .idName)
        self.idType = try container.decode(String.self, forKey: .idType)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.channel = nil  // Not decoded from attributes
        self.location = try container.decodeIfPresent(LocationData.self, forKey: .location)
    }
}

