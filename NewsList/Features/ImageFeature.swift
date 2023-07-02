import Foundation
import ComposableArchitecture
import SwiftUI

struct ImageFeature: ReducerProtocol {
    
    struct State: Equatable {
        var image: UIImage?
    }
    enum Action {
        case load(URL)
        case response(URL, UIImage?)
    }
    
    @Dependency(\.networkClient) var networkClient
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .load(let url):
                return .run { send in
                    if let image = await networkClient.loadImage(url: url) {
                        await send(.response(url, image))
                    }
                }
            case let .response(_, image):
                state.image = image
                return .none
            }
        }
    }
}
