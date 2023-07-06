import SwiftUI

import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<NewsListFeature>

    var body: some View {
       ItemsListView(store: store)
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
