import Foundation
import ComposableArchitecture

struct FlagFeature: ReducerProtocol {
    struct State: Equatable {
        var flag: Bool
    }
    enum Action {
        case swap
    }
    func reduce(into state: inout State,
                action: Action) -> EffectTask<Action> {
        switch action {
        case .swap: state.flag = !state.flag
        }
        return .none
    }
}
