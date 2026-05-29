import SwiftUI
import LowCodeMobile

public struct PromotionsAndOffersView: View {
    let model: PromotionsAndOffersModel
    let context: ComponentContext
    
    public var body: some View {
        if !model.items.isEmpty {
            VStack(alignment: .leading) {
                ForEach(model.items) { item in
                    AsyncImage(url: URL(string: item.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

