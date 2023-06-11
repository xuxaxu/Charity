import Foundation
import ComposableArchitecture

struct SourceFeature: ReducerProtocol {
    
    struct State: Equatable {
        var source: Source
        var on: Bool
    }
    enum Action {
        case on
        case off
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .off: state.on = false
        case .on: state.on = true
        }
        return .none
    }
}
