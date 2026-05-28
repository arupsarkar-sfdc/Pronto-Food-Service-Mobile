import Foundation
import Personalization
import LowCodeMobile

public struct PromotionsAndOffersModel: ComponentModel {

    public let items: [PromotionsAndOffersItem]
    
    public init(items: [PromotionsAndOffersItem]) {
        self.items = items
    }
}

public struct PromotionsAndOffersItem : Codable, Identifiable {

    public let imageUrl: String
    public let id: String
    
    public init(id: String?, imageUrl: String? = nil){
        self.imageUrl = imageUrl ?? ""
        self.id = id ?? "-"
    }
}
