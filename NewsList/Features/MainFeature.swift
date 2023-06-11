import Foundation
import ComposableArchitecture

struct Feature: ReducerProtocol {
    
    struct State: Equatable {
        var sources = [Source]()
    }
    
    enum Actions {
        case sources
        case newsList
    }
    
    func reduce(into state: inout State,
                action: Actions) -> EffectTask<Actions> {
        switch action {
        case .newsList:
            return .none
        case .sources:
            return .none
        }
    }

}

extension Feature.State {
    var sourcesState: SourcesFeature.State {
        get {
            SourcesFeature.State(sources: sources,
                                 alertSourcesMoreThan20: true)
        }
        set {
            self.sources = newValue.sources
        }
    }
}
