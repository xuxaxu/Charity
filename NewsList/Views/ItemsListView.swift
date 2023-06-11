import SwiftUI
import CoreData
import ComposableArchitecture

struct ItemsListView: View {
    let store: StoreOf<NewsListFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            NavigationView {
                VStack {
                    HStack {
                        NavigationLink { ChooseSourcesView(store: viewStore.view(value: { $0.sourcesState},
                                                                             action: { viewStore.sources($0) })) } label: { Text("setup domains") }
                            .padding(DesignSizes.bigOffset)
                        Spacer()
                        Button("get news") {
                            store.send(.reload)
                        }
                        .padding(DesignSizes.bigOffset)
                    }
                    List {
                        ForEach(viewStore.items) { item in
                            NavigationLink {
                                let id = item.id
                                DetailView(store: viewStore.view(value: { $0.items.first(where: { $0.id == id })! }, action: { $0 }))
                            } label: {
                                HStack {
                                    if let image = item.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .controlSize(.mini)
                                            .scaledToFit()
                                            .cornerRadius(DesignSizes.cornerRadius)
                                    }
                                    Text(item.title)
                                    Text(String(viewStore.detailed[item.id] ?? 0))
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text(viewStore.domains)
                            .lineLimit(3)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct ItemsListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let state = NewsListFeature.State(sources: [])
        let store = Store(initialState: state,
                          reducer: NewsListFeature())
        ItemsListView(store: store)
    }
}
