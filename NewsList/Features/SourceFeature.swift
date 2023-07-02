import Foundation
import ComposableArchitecture

struct SourceFeature: ReducerProtocol {
    
    struct State: Equatable {
        var source: Source
        var on: Bool
        @PresentationState var flagState: FlagFeature.State?
    }
    enum Action {
        case start(PresentationAction<FlagFeature.Action>)
        case swap(PresentationAction<FlagFeature.Action>)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                state.flagState = FlagFeature.State(flag: state.on)
            case .swap:
                guard let flag = state.flagState?.flag else {
                    return .none
                }
                state.on = flag
                state.flagState = nil
            }
            return .none
        }
        .ifLet(\.$flagState, action: /Action.swap) {
            FlagFeature()
        }
    }
}

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
