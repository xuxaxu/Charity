import Foundation

enum SourcesAction {
    case load
    case on(Int)
    case off(Int)
    case set([Source])
    case closeAlert
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
        if state.sources.filter({ $0.include }).count > 20 {
            state.sources[index] = Source(state.sources[index], include: false)
            state.alertSourcesMoreThan20 = true
        }
    case .off(let index):
        state.sources[index] = Source(state.sources[index], include: false)
    case .set(let sources):
        state.sources = sources
    case .closeAlert:
        state.alertSourcesMoreThan20 = false
    }
    return []
}
