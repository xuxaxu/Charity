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
                        action: { viewStore.send(.swap)},
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
