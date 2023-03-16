import SwiftUI

struct ChooseSourcesView: View {
    @ObservedObject var store: Store<SourcesState, SourcesAction>
    var body: some View {
        NavigationView {
            VStack {
                Button("get sources") {
                    store.send(.load)
                }
            }
            List {
                ForEach(store.value.sources.indices) { item in
                    Text(store.value.sources[item])
                }
            }
        }
    }
}

struct ChooseSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(value: SourcesState(state: AppState()), reducer: sourceReducer)
        ChooseSourcesView(store: store)
    }
}
