import Foundation

enum SourcesAction {
    case load
    case on(Int)
    case off(Int)
    case set([Source])
    case empty
    case finish
}

enum FlagAction {
    case on
    case off
}

func sourceReducer(state: inout SourcesState, action: SourcesAction) -> [Effect<SourcesAction>] {
    switch action {
    case .load:
        return [CurrentSurces.load().map{ .set($0) }.recieve(on: .main)]
    case .on(let index):
        state.sources[index] = Source(state.sources[index], include: true)
    case .off(let index):
        state.sources[index] = Source(state.sources[index], include: false)
    case .set(let sources):
        state.sources = sources
    case .empty:
        break
    case .finish:
        break
    }
    return []
}
