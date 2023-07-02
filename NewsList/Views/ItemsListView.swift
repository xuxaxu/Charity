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
                        NavigationLink { ChooseSourcesView(store: Store( initialState: SourcesFeature.State(sources: viewStore.sources, alertSourcesMoreThan20: true),  reducer: SourcesFeature()))}  label: { Text("setup domains") }
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
                                DetailView(store: Store(initialState: ArticleFeature.State(article: item), reducer: ArticleFeature()))
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
