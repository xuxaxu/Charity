import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction<Article>>

    var body: some View {
       ItemsListView(store: store)
        //ChooseSourcesView(store: Store(value: store.value.sourcesState, reducer: sourceReducer))
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @State static var state = AppState()
    @State static var store = Store(value: state,
                                    reducer: appReducer)
    
    static var previews: some View {
        ContentView(store: store)
    }
}
