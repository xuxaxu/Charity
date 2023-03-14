import Foundation
import SwiftUI

struct AppState {
    var items: [Article] = []
    var detailed: [UUID: Int] = [:]
    var activityFeed: [Activity] = []
    var dataFromPersistance = false
    var currentPage = 1
    
}

struct NewsListView {
    private var state: AppState
    
    init(state: AppState) {
        self.state = state
    }
    
    var newsItems: [NewsListItem] {
        var items = [NewsListItem]()
        for item in self.state.items {
            items.append(NewsListItem(from: item,
                                      detailed: self.state.detailed[item.id] ?? 0))
        }
        return items
    }
}

struct LoadState {
    private var state: AppState
    init(state: AppState) {
        self.state = state
    }
    var items: [Article] {
        get {
            state.items
        }
        set {
            state.items = newValue
        }
    }
    var currentPage: Int {
        get {
            state.currentPage
        }
        set {
            state.currentPage = newValue
        }
    }
    var dataFromPersistance: Bool {
        get {
            state.dataFromPersistance
        }
        set {
            state.dataFromPersistance = newValue
        }
    }
}

extension AppState {
    
    var loadState: LoadState {
        get {
            LoadState(state: self)
        }
        set {
            self.items = newValue.items
            self.dataFromPersistance = newValue.dataFromPersistance
            self.currentPage = newValue.currentPage
        }
    }
    var newsListState: NewsListView {
        get {
            return NewsListView(state: self)
        }
        set {}
    }
}
