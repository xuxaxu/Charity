import Foundation

enum SourcesAction {
    case load
    case tap(Int)
}

func sourceReducer(state: inout SourcesState, action: SourcesAction) -> [Effect<SourcesAction>] {
    switch action {
    case .load:
        let dataEffect = getSourcesRequest.map{ $0 == nil ? nil : CurrentItemsWithImage.loadData(request: $0!) }
        
    case .tap(let index):
        state.selected[index] = !state.selected[index]
    }
    return []
}
