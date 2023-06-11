import SwiftUI
import ComposableArchitecture

@main
struct NewsListApp: App {
    let persistenceController = PersistenceController.shared
    
    @State var store = Store(initialState: NewsListFeature.State(sources: []),
                      reducer: NewsListFeature()._printChanges(),
                      prepareDependencies: {_ in})
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

