import SwiftUI
import Personalization
import LowCodeMobile

public class ProductRecommendations: Component {
    public static let name = "ProductRecommendations"
    
    public typealias Content = ProductRecommendationsView
    public typealias Model = ProductRecommendationsModel
    

    public init() {}
    

    public func validateAndCreateComponentModel(from data: Data) throws -> ProductRecommendationsModel {
        // Step 1: Decode JSON to model (checks structure/types)
        let decoder = JSONDecoder()
        let model = try decoder.decode(ProductRecommendationsModel.self, from: data)

        return model
    }
    
    public func compose(
        model: ProductRecommendationsModel,
        isPreview: Bool
    ) -> Content {
        return ProductRecommendationsView(model: model)
    }
}
