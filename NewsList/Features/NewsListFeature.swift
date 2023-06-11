import Foundation
import ComposableArchitecture
import SwiftUI

struct NewsListFeature: ReducerProtocol {
    
    @PresentationState var updateSources: SourcesFeature.State?
    
    struct State: Equatable {
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

    func reduce(into state: inout State,
                action: AppAction<Article>) -> EffectTask<AppAction<Article>> {
        switch action {
        case .items(let itemAction):
            return itemsReducer(state: &state.items,
                                action: itemAction).map{ .items($0) }
        default:
            return dataReducer(state: &state.loadState, action: action)
        }
    }
    
    enum AppAction<Item: ItemWithImage> {
        case reload
        case nextPortion
        case items(ItemsAction<Item>)
        
        var items: ItemsAction<Item>? {
            get {
                guard case let .items(itemsAction) = self else {
                    return nil
                }
                return itemsAction
            }
            set {
                guard case .items = self, let newValue = newValue else {
                    return
                }
                self = .items(newValue)
            }
        }
        
        var keySelf: AppAction<Item>? {
            get {
                self
            }
            set {
                guard let newValue else {
                    return
                }
                self = newValue
            }
        }
        
        var images: ImagesAction<Item>? {
            get {
                guard case let .items(.image(imageAction)) = self else {
                    return nil
                }
                return imageAction
            }
            set {
                guard case .items(.image) = self, let newValue = newValue else {
                    return
                }
                self = .items(.image(newValue))
            }
        }
    }
    
    enum ItemsAction<Item: ItemWithImage>: Equatable {
        
        case addItem(Item)
        case clear
        case set([Item])
        case image(ImagesAction<Item>)
        
        static func == (lhs: ItemsAction<Item>, rhs: ItemsAction<Item>) -> Bool {
            switch lhs {
            case .image(let imageAction):
                switch rhs {
                case .image(let rhsImageAction):
                    return imageAction == rhsImageAction
                default:
                    return false
                }
            case .set(let arr):
                switch rhs {
                case .set(let rhsArr):
                    return arr == rhsArr
                default:
                    return false
                }
            case .addItem(let item):
                switch rhs {
                case .addItem(let rhsItem):
                    return item == rhsItem
                default:
                    return false
                }
            case .clear:
                switch rhs {
                case .clear:
                    return true
                default:
                    return false
                }
            }
        }
    }
    
    enum ImagesAction<Item: ItemWithImage>: Equatable {
        case addImage(URL, UIImage)
        case load(URL)
        case empty
    }
    
    @Dependency(\.networkClient) var networkClient
    
    func itemsReducer<Item: ItemWithImage>(state: inout [Item],
                                           action: ItemsAction<Item>) -> EffectTask<ItemsAction<Item>> {
        switch action {
        case .addItem(let item):
            state.append(item)
            if let url = item.urlToImage {
                return .run { send in
                    guard let image = await networkClient.loadImage(url: url) else {
                        return
                    }
                    await send(.image(.addImage(url, image)))
                }
            }
        case .clear:
            state = []
        case .set(let items):
            state = items
            return .run { send in
                for item in items {
                    if let url = item.urlToImage {
                        await send(.image(.load(url)))
                    }
                }
            }
        default:
            break
        }
        return .none
    }

    func imageReducer<Item: ItemWithImage>(state: inout [Item],
                                           action: ImagesAction<Item>) -> EffectTask<ImagesAction<Item>> {
        switch action {
        case let .addImage(url, image):
            let indices = state.indices.filter{ state[$0].urlToImage == url }
            for index in indices {
                state[index].image = image
            }
        case let .load(url):
            return .run { send in
                if let image = await networkClient.loadImage(url: url) {
                    await send(.addImage(url, image))
                }
            }
        case .empty:
            break
        }
        return .none
    }

    @Dependency(\.articleNetwork) var articleNetworkClient
    
    func dataReducer(state: inout LoadState, action: AppAction<Article>) -> EffectTask<AppAction<Article>> {
        switch action {
        case .reload:
            state.currentPage = 1
            let domain = state.domains
            state.dataFromPersistance = false
            return .run { [domain] send in
                await send(.items(.clear))
                do {
                    let effects = try await self.articleNetworkClient.load(domain, 1)
                    await send(.items(.set(effects)))
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
                let itemEffects = try await articleNetworkClient.load(domains, page)
                await send(.items(.set(itemEffects)))
            }
        default:
            break
        }
        return .none
    }

}

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

