import SwiftUI
import Personalization

public class PromoCard: Personalization.Component {
    public static let name = "PromoCard"
    
    public typealias Content = PromoCardView
    public typealias Model = PromoCardModel

    public init() { }

    public func validateAndCreateComponentModel(from data: Data) throws -> PromoCardModel {
        let decoder = JSONDecoder()
        let model = try decoder.decode(PromoCardModel.self, from: data)

        try model.validate()

        return model
    }

    public func compose(model: PromoCardModel, isPreview: Bool) -> Content {
        return PromoCardView(model: model)
    }
}
