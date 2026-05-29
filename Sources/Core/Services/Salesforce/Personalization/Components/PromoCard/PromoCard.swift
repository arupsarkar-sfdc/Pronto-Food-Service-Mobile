import SwiftUI
import Personalization
import LowCodeMobile

public class PromoCard: Component {
    public static let name = "PromoCard"
    
    public typealias Content = PromoCardView
    public typealias Model = PromoCardModel

    public init() { }

    public func validateAndCreateComponentModel(unvalidatedJson: Data, componentContext: ComponentContext) throws  -> PromoCardModel {
        let decoder = JSONDecoder()
        let model = try decoder.decode(PromoCardModel.self, from: unvalidatedJson)

        try model.validate()

        return model
    }

    public func compose(
        model: PromoCardModel,
        componentContext: ComponentContext
    ) -> Content {
        return PromoCardView(model: model, componentContext: componentContext)
    }
}
