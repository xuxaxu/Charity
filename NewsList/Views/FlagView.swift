import SwiftUI
import ComposableArchitecture

struct FlagView: View {
    let store: StoreOf<FlagFeature>
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0 }) { viewStore in
                VStack {
                    Button(
                        action: { viewStore.send( viewStore.flag ? .off : .on)},
                        label: {viewStore.flag ?
                        Label("", systemImage: "checkmark.circle")
                            .foregroundColor(.green) :
                        Label("", systemImage: "circle")
                        .foregroundColor(.gray) })
                }
            }
    }
}

struct FlagView_Previews: PreviewProvider {
    static var previews: some View {
        FlagView(store: Store(initialState: FlagFeature.State(flag: false), reducer: FlagFeature()))
    }
}

struct FlagFeature: ReducerProtocol {
    struct State: Equatable {
        var flag: Bool
    }
    enum Action {
        case on
        case off
    }
    func reduce(into state: inout State,
                action: Action) -> EffectTask<Action> {
        switch action {
        case .off: state.flag = false
        case .on: state.flag = true
        }
        return .none
    }
}
