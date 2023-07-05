import Foundation
import ComposableArchitecture

struct SourcesFeature: ReducerProtocol {
      
    struct State: Equatable {
        
        var sources: [Source]
        var alertSourcesMoreThan20: Bool
    }
    
    enum Action {
        case load
        case swap(UUID)
        case set([Source])
        case closeAlert
        case finSelect
    }
    
    @Dependency(\.sources) var sourcesNetworkClient
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                return .run{ send in
                    do {
                        let sources = try await self.sourcesNetworkClient.load()
                        await send(.set(sources))
                    }
                }
            case let .swap(id):
                let sourceIndices = state.sources.indices.filter{ state.sources[$0].id == id }
                for index in sourceIndices {
                    state.sources[index] = Source(state.sources[index],
                                                  include: !state.sources[index].include)
                }
                if (state.sources.filter({ $0.include }).count > 20) {
                    for index in sourceIndices {
                        state.sources[index] = Source(state.sources[index], include: false)
                    }
                    state.alertSourcesMoreThan20 = true
                }
            case .set(let sources):
                state.sources = sources
            case .closeAlert:
                state.alertSourcesMoreThan20 = false
            case .finSelect:
                return .none
            }
            return .none
        }
    }
}
