import SwiftUI
import CoreData

struct ItemsListView: View {
    @ObservedObject var store: Store<AppState, AppAction<Article>>

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink { ChooseSourcesView(store: store.view(value: { $0.sourcesState},
                                                                         action: { .sources($0) })) } label: { Text("setup domains") }
                        .padding(DesignSizes.bigOffset)
                    Spacer()
                    Button("get news") {
                        store.send(.reload)
                    }
                    .padding(DesignSizes.bigOffset)
                }
                List {
                    ForEach(store.value.items) { item in
                        NavigationLink {
                            let id = item.id
                            DetailView(store: store.view(value: { $0.items.first(where: { $0.id == id })! }, action: { $0 }))
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
                                Text(String(store.value.detailed[item.id] ?? 0))
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(store.value.domains)
                        .lineLimit(3)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct ItemsListView_Previews: PreviewProvider {
    
    @State static var state = AppState()
    @State static var store = Store(value: state,
                                    reducer: appReducer)
    
    static var previews: some View {
        ItemsListView(store: store)
    }
}
