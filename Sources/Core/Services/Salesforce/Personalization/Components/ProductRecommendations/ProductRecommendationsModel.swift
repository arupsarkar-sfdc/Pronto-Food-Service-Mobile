import Foundation
import Personalization
import LowCodeMobile

public struct ProductRecommendationsModel: ComponentModel {

    public let sectionHeader: String?
    public let items: [RecommendedProduct]
    
    public init(sectionHeader: String? = nil, items: [RecommendedProduct]) {
        self.sectionHeader = sectionHeader
        self.items = items
    }
}

public struct RecommendedProduct : Codable {

    public let id: String

    public let name: String

    public let imageUrl: String

    public let url: String

    public let description: String
    
    public init(id: String?, name: String?, imageUrl: String? = nil, url: String?, description: String?){
        self.id = id ?? ""
        self.name = name ?? ""
        self.url = url ?? ""
        self.imageUrl = imageUrl ?? ""
        self.description = description ?? ""
    }
}
