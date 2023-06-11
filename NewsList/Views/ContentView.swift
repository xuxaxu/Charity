import SwiftUI
import CoreData
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<NewsListFeature>

    var body: some View {
       ItemsListView(store: store)
        //ChooseSourcesView(store: Store(value: store.value.sourcesState, reducer: sourceReducer))
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let state = NewsListFeature.State(sources: [])
        let store = Store(initialState: state,
                          reducer: NewsListFeature())
        ContentView(store: store)
    }
}
