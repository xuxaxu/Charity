import SwiftUI

struct ChooseSourcesView: View {
    @ObservedObject var store: Store<SourcesState, SourcesAction>
    var body: some View {
        NavigationView {
            VStack {
                Button("get sources") {
                    store.send(.load)
                }
                List {
                    ForEach(store.value.sources) { item in
                        SourceView(store: store.view(value: {$0.sources[$0.sources.firstIndex(where: { $0.id == item.id})!]},
                                                     action: { action in
                            let index = store.value.sources.firstIndex(where: {$0.id == item.id})!
                            return action == .on ? .on(index) : .off(index)}))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("choose sources of news")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ChooseSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        let netSource = NetworkSource(id: "123", name: "bbc news", description: nil, category: nil, language: nil, country: "us")
        let appState = AppState(sources: [Source(netSource)])
        let state = SourcesState(state: appState)
        let store = Store(value: state,
                          reducer: sourceReducer)
        ChooseSourcesView(store: store)
    }
}
