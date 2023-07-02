import SwiftUI
import ComposableArchitecture

struct ChooseSourcesView: View {
    let store: StoreOf<SourcesFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            NavigationView {
                VStack {
                    Button("get sources") {
                        viewStore.send(.load)
                    }
                    List {
                        ForEach(viewStore.sources) { item in
                                SourceView(store: Store(initialState: SourceFeature.State(source: item, on: item.include), reducer: SourceFeature()))
                        }
                    }
                    /*
                     .alert(isPresented: Binding(get: { self.store.value.alertSourcesMoreThan20 },
                     set: {_ in})) {
                     Alert(title: Text("21 sources choosen"),
                     message: Text("more than 20 sources is forbidden"),
                     dismissButton: .default(Text("OK")))
                     }
                     */
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
}

struct ChooseSourcesView_Previews: PreviewProvider {
    static var previews: some View {
        let netSource = NetworkSource(id: "123",
                                      name: "bbc news",
                                      description: nil,
                                      category: nil,
                                      language: nil,
                                      country: "us")
        let state = SourcesFeature.State(sources: [Source(netSource)], alertSourcesMoreThan20: true)
        let store = Store(initialState: state,
                          reducer: SourcesFeature())
        ChooseSourcesView(store: store)
    }
}
