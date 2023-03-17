import Foundation
import SwiftUI

enum AppAction<Item: ItemWithImage> {
    case reload
    case nextPortion
    case items(ItemsAction<Item>)
    case sources(SourcesAction)
    
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
    var sources: SourcesAction? {
        get {
            guard case let .sources(sourcesAction) = self else {
                return nil
            }
            return sourcesAction
        }
        set {
            guard case .sources = self, let newValue = newValue else {
                return
            }
            self = .sources(newValue)
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
    case empty
}

let appReducer: Reducer<AppState, AppAction<Article>> = combine(pullback(itemsReducer,
                                                                         value: \.items,
                                                                         action: \.items),
                                                                pullback(dataReducer,
                                                                         value: \.loadState,
                                                                         action: \.keySelf ),
                                                                pullback(imageReducer,
                                                                         value: \.items,
                                                                         action: \.images),
                                                                pullback(sourceReducer,
                                                                         value: \.sourcesState,
                                                                         action: \.sources))

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}

func itemsReducer<Item: ItemWithImage>(state: inout [Item], action: ItemsAction<Item>) -> [Effect<ItemsAction<Item>>] {
    switch action {
    case .addItem(let item):
        state.append(item)
    case .clear:
        state = []
    case .set(let arr):
        state = arr
        var effects = [Effect<ImagesAction<Item>>]()
        for item in state {
            if let url = item.urlToImage {
                let imageActionEffect: Effect<ImagesAction<Item>> = CurrentNetworkClient.loadImage(url: url)
                    .map{ $0 == nil ? .empty : .addImage(url, $0!) }
                effects.append(imageActionEffect)
            }
        }
        return effects.map{ $0.map{ .image($0) } }
    default:
        break
    }
    return []
}

func imageReducer<Item: ItemWithImage>(state: inout [Item], action: ImagesAction<Item>) -> [Effect<ImagesAction<Item>>] {
    switch action {
    case let .addImage(url, image):
        let indices = state.indices.filter{ state[$0].urlToImage == url }
        for index in indices {
            state[index].image = image
        }
    case .empty:
        break
    }
    return []
}

func dataReducer(state: inout LoadState, action: AppAction<Article>) -> [Effect<AppAction<Article>>] {
    var effects = [Effect<AppAction<Article>>]()
    switch action {
    case .reload:
        effects.append( Effect { callback in callback(.items(.clear)) })
        state.currentPage = 1
        state.dataFromPersistance = false
        let page = state.currentPage
        let effect = CurrentArticleNetwork.load(state.domains, state.currentPage)  //makeLoadArticlesEffect(page) {
            effects.append(effect.map{ .items(.set($0))})
        
    case .nextPortion:
        guard !state.dataFromPersistance else {
            return []
        }
        state.currentPage += 1
        let page = state.currentPage
        if let effect = makeLoadArticlesEffect(page) {
            effects.append(effect)
        }
    default:
        break
    }
    
    return effects
}

func makeLoadArticlesEffect(_ page: Int) -> Effect<AppAction<Article>>? {
    return Effect { callback in
        let newsListService = NewsListNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default)))
        let parser = ArticleNetworkParserImp()
        newsListService.getNews(page: page) { result in
            switch result {
            case .failure:
                callback(.items(.clear))
            case .success(let response):
                var items = [Article]()
                for netArticle in response.articles {
                    if let article = parser.parse(article: netArticle) {
                        items.append(article)
                    }
                }
                callback(.items(.set(items)))
            }
        }
    }
}
