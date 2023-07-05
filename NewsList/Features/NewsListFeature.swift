import Foundation
import ComposableArchitecture
import SwiftUI

struct NewsListFeature: ReducerProtocol {
    
    struct State: Equatable {
        @PresentationState var itemsControl: ItemsFeature.State?
        @PresentationState var updateSources: SourcesFeature.State?
        
        static func == (lhs: NewsListFeature.State, rhs: NewsListFeature.State) -> Bool {
            return false
        }
        
        var items: [Article] = []
        var detailed: [UUID: Int] = [:]
        var activityFeed: [Activity] = []
        var dataFromPersistance = false
        var currentPage = 1
        var sources: [Source]
        var domains: String {
            sources.filter{ $0.include }.reduce("", { $0.isEmpty ? $1.requestId : $0 + "," + $1.requestId } )
        }
    }
    
    enum Action {
        case reload
        case nextPortion
        case items(PresentationAction<ItemsFeature.Action>)
        case chooseSources
        case finChooseSources(PresentationAction<SourcesFeature.Action>)
    }
    
    @Dependency(\.articleNetwork) var articleNetworkClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .items:
                guard let items = state.itemsControl?.items as? [Article] else {
                    return .none
                }
                state.items = items
                state.itemsControl = nil
            case .chooseSources:
                state.updateSources = SourcesFeature.State(sources: state.sources,
                                                           alertSourcesMoreThan20: false)
            case .finChooseSources(.presented(.finSelect)):
                guard let sources = state.updateSources?.sources else {
                    return .none
                }
                state.sources = sources
                state.updateSources = nil
                return .none
            case .reload:
                state.currentPage = 1
                let domain = state.domains
                state.dataFromPersistance = false
                state.itemsControl = ItemsFeature.State(items: state.items,
                                                        imageFeature: ImageFeature.State())
                return .run { [domain] send in
                    do {
                        let effects = try await self.articleNetworkClient.load(domain, 1)
                        await send(.items(.presented(.set(effects))))
                    }
                }
                
            case .nextPortion:
                guard !state.dataFromPersistance else {
                    return .none
                }
                state.currentPage += 1
                let page = state.currentPage
                let domains = state.domains
                state.itemsControl = ItemsFeature.State(items: state.items, imageFeature: ImageFeature.State())
                return .run { send in
                    let items = try await articleNetworkClient.load(domains, page)
                    await send(.items(.presented(.set(items))))
                }
            case .finChooseSources:
                return .none
            }
            return .none
        }
        .ifLet(\.$updateSources, action: /Action.finChooseSources) {
            SourcesFeature()
        }
        .ifLet(\.$itemsControl, action: /Action.items) {
            ItemsFeature()
        }
    }
        
}
