import SwiftUI
import Personalization
import LowCodeMobile

public class PromotionsAndOffers: Component {
    public static let name = "Promotions_and_Offers"
    
    public typealias Content = PromotionsAndOffersView
    public typealias Model = PromotionsAndOffersModel
    

    public init() {}
    

    public func validateAndCreateComponentModel(from data: Data) throws -> PromotionsAndOffersModel {
        // Step 1: Decode JSON to model (checks structure/types)
        let decoder = JSONDecoder()
        let model = try decoder.decode(PromotionsAndOffersModel.self, from: data)

        return model
    }
    
    public func compose(
        model: PromotionsAndOffersModel,
        isPreview: Bool
    ) -> Content {
        return PromotionsAndOffersView(model: model)
    }
}
