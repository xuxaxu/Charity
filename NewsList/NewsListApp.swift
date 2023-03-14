import SwiftUI

@main
struct NewsListApp: App {
    let persistenceController = PersistenceController.shared
    
    var store = Store(value: AppState(), reducer: appReducer)

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

