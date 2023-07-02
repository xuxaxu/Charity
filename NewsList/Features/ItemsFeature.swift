import Foundation
import ComposableArchitecture
import SwiftUI

struct ItemsFeature: ReducerProtocol {
      
    struct State {
        var items: [any ItemWithImage] = []
        @PresentationState var imageFeature: ImageFeature.State?
    }
    enum Action {
        case addItem(any ItemWithImage)
        case clear
        case set([any ItemWithImage])
        case addImage(URL, UIImage)
        case loadImage(PresentationAction<ImageFeature.Action>)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .addItem(let item):
                state.items.append(item)
            case .clear:
                state.items = []
            case .set(let items):
                state.items = items
                return .run { send in
                    for item in items {
                        if let url = item.urlToImage {
                            await send(.loadImage(.presented(.load(url))))
                        }
                    }
                }
            case let .addImage(url, image):
                let itemsWithUrl = state.items.indices.filter{ state.items[$0].urlToImage == url }
                for index in itemsWithUrl {
                    state.items[index].image = image
                }
            case let .loadImage(.presented(.response(url, image))):
                if let image = image {
                    return .run { send in
                        await send(.addImage(url, image))
                    }
                }
            case .loadImage:
                return .none
            }
            return .none
        }
        .ifLet(\.$imageFeature, action: /Action.loadImage) {
            ImageFeature()
        }
    }
}
