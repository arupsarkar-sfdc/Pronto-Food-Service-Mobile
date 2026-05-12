import Foundation
import Personalization

public struct PromoCardModel: Personalization.ComponentModel {

    public let header: String?
    public let subheader: String?
    public let text: String?
    public let backgroundColor: String?
    public let imageUrl: String?
    public let ctaText: String?
    public let ctaUrl: String?
    
    public init(header: String, subheader: String? = nil, text: String? = nil, imageUrl: String, ctaText: String? = nil, ctaUrl: String? = nil, backgroundColor: String? = nil) {
        self.header = header
        self.subheader = subheader
        self.imageUrl = imageUrl
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.text = text
        self.backgroundColor = backgroundColor
    }
    

    internal func validate() throws { }
}
