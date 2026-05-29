import SwiftUI
import Personalization
import LowCodeMobile

public class PromotionsAndOffers: Component {
    public static let name = "Promotions_and_Offers"
    
    public typealias Content = PromotionsAndOffersView
    public typealias Model = PromotionsAndOffersModel
    

    public init() {}
    

    public func validateAndCreateComponentModel(unvalidatedJson: Data, componentContext: ComponentContext) throws -> PromotionsAndOffersModel {
        // Step 1: Decode JSON to model (checks structure/types)
        let decoder = JSONDecoder()
        let model = try decoder.decode(PromotionsAndOffersModel.self, from: unvalidatedJson)

        return model
    }
    
    public func compose(
        model: PromotionsAndOffersModel,
        componentContext: ComponentContext
    ) -> Content {
        return PromotionsAndOffersView(model: model, context: componentContext)
    }
}
