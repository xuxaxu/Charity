import SwiftUI
import ComposableArchitecture

@main
struct NewsListApp: App {
    
    @State var store = Store(initialState: NewsListFeature.State(sources: []),
                      reducer: NewsListFeature()._printChanges(),
                      prepareDependencies: {_ in})
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

