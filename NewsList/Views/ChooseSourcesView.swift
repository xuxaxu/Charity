import SwiftUI
import ComposableArchitecture

struct ChooseSourcesView: View {
    let store: StoreOf<SourcesFeature>
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    ForEach(viewStore.sources, id: \.id) { item in
                        HStack {
                            SourceView(store: Store(initialState: SourceFeature.State(source: item), reducer: SourceFeature()))
                            Spacer()
                            Button {
                                viewStore.send(.swap(item.id))
                            } label: {
                                FlagView(flag: item.include)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    self.store.send(.load)
                } label: {
                    Text("get sources")
                }
            }
            ToolbarItem {
                Button {
                    self.store.send(.fin)
                } label: {
                    Text("done")
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
