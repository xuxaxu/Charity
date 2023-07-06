import Foundation
import ComposableArchitecture
import SwiftUI

struct NewsListFeature: ReducerProtocol {
    
    struct State: Equatable {
        
        @PresentationState var updateSources: SourcesFeature.State?
        
        static func == (lhs: NewsListFeature.State, rhs: NewsListFeature.State) -> Bool {
            return false
        }
        
        var items: [Article] = []
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
        case addItem(Article)
        case clear
        case set([Article])
        case addImage(URL, UIImage)
        case loadImage(URL)
        case chooseSources
        case finChooseSources(PresentationAction<SourcesFeature.Action>)
    }
    
    @Dependency(\.articleNetwork) var articleNetworkClient
    @Dependency(\.networkClient) var networkClient

    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .addItem(let item):
                state.items.append(item)
            case .clear:
                state.items = []
            case .set(let items):
                state.items = items
                return .run { send in
                    for item in items {
                        if let url = item.urlToImage {
                            await send(.loadImage(url))
                        }
                    }
                }
            case let .addImage(url, image):
                let itemsWithUrl = state.items.indices.filter{ state.items[$0].urlToImage == url }
                for index in itemsWithUrl {
                    state.items[index].image = image
                }
            case .loadImage(let url):
                return .run { send in
                    if let image = await networkClient.loadImage(url: url) {
                        await send(.addImage(url, image))
                    }
                }
            case .chooseSources:
                state.updateSources = SourcesFeature.State(sources: state.sources,
                                                           alertSourcesMoreThan20: false)
            case .finChooseSources(.presented(.delegate(.finSelect))):
                guard let sources = state.updateSources?.sources else {
                    return .none
                }
                state.sources = sources
                return .run { send in
                    await send(.reload)
                }
            case .reload:
                state.currentPage = 1
                let domain = state.domains
                state.dataFromPersistance = false
                return .run { [domain] send in
                    do {
                        let effects = try await self.articleNetworkClient.load(domain, 1)
                        await send(.set(effects))
                    }
                }
                
            case .nextPortion:
                guard !state.dataFromPersistance else {
                    return .none
                }
                state.currentPage += 1
                let page = state.currentPage
                let domains = state.domains
                return .run { send in
                    let items = try await articleNetworkClient.load(domains, page)
                    await send(.set(items))
                }
            case .finChooseSources:
                return .none
            }
            return .none
        }
        .ifLet(\.$updateSources, action: /Action.finChooseSources) {
            SourcesFeature()
        }
    }
        
}
