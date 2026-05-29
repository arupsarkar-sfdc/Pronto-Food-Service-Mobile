import SwiftUI
import Personalization
import LowCodeMobile

public class ProductRecommendations: Component {
    public static let name = "ProductRecommendations"
    
    public typealias Content = ProductRecommendationsView
    public typealias Model = ProductRecommendationsModel
    

    public init() {}
    

    public func validateAndCreateComponentModel(unvalidatedJson: Data, componentContext: ComponentContext) throws -> ProductRecommendationsModel {
        // Step 1: Decode JSON to model (checks structure/types)
        let decoder = JSONDecoder()
        let model = try decoder.decode(ProductRecommendationsModel.self, from: unvalidatedJson)

        return model
    }
    
    public func compose(
        model: ProductRecommendationsModel,
        componentContext: ComponentContext
    ) -> Content {
        return ProductRecommendationsView(model: model, context: componentContext)
    }
}
