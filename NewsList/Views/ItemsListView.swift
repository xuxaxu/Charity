import SwiftUI
import CoreData
import ComposableArchitecture

struct ItemsListView: View {
    let store: StoreOf<NewsListFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    ForEach(viewStore.items) { item in
                            NavigationLink {
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.store.send(.chooseSources)
                        } label: { Text("setup domains") }
                    }
                }
            }
        }
        .sheet(
            store: self.store.scope(
                state: \.$updateSources,
                action: { .finChooseSources($0)})
        ) { chooseSourcesStore in
            NavigationStack{
                ChooseSourcesView(store: chooseSourcesStore)
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
