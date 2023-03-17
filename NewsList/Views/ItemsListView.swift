import SwiftUI
import CoreData

struct ItemsListView: View {
    @ObservedObject var store: Store<AppState, AppAction<Article>>

    var body: some View {
        NavigationView {
            VStack {
                Button("get \(Constants.domains)") {
                    store.send(.reload)
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
                    Text(Constants.domains)
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
