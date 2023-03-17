import Foundation

#if DEBUG
var CurrentArticleNetwork = ArticleNetworkEnvironment.live //.mock
#else
let CurrentArticleNetwork = ArticleNetworkEnvironment.live
#endif

struct ArticleNetworkEnvironment {
    var restClient: RestClient
    
    var urlRequest: (String, Int) -> URLRequest?
    
    var parseNetworkArticles: (Data?) -> [NetworkArticle]
    
    var getArticles: ([NetworkArticle]) -> [Article]
    
    public func load(_ domains: String, _ page: Int) -> Effect<[Article]> {
        guard let request = urlRequest(domains, page) else {
            return Effect{ callback in
                callback([])
            }
        }
        return restClient.request(request)
            .map(restClient.getData)
            .map(parseNetworkArticles)
            .recieve(on: .global())
            .map(getArticles)
            .recieve(on: .main)
    }
}

extension ArticleNetworkEnvironment {
    static let live = ArticleNetworkEnvironment(restClient: .live,
                                                urlRequest: getArticlesRequest,
                                                parseNetworkArticles: parseNetworkArticle,
                                                getArticles: getArticleFromNetworkArticle)
    static let mock = ArticleNetworkEnvironment(restClient: .mock,
                                                urlRequest: {_,_ in nil},
                                                parseNetworkArticles: {_ in []},
                                                getArticles:  {_ in []})
}

let parseNetworkArticle: (Data?) -> [NetworkArticle] = { data in
    guard let data else {
        return []
    }
    guard let articles = try? JSONDecoder().decode(NetworkModel.self, from: data).articles else {
        return []
    }
    return articles
}

let getArticleFromNetworkArticle: ([NetworkArticle]) -> [Article] = { netArticles in
    let parser = ArticleNetworkParserImp()
    return netArticles.compactMap{ parser.parse(article: $0) }
}

let getArticlesRequest: (String, Int) -> URLRequest? = { domains, page in
    let appendingString = "/everything"

    let queryItems = [
        URLQueryItem(name: "page", value: String(page)),
        URLQueryItem(name: "pageSize", value: String(Constants.pageSize)),
        URLQueryItem(name: "sources", value: domains)
    ]
    var urlComponents = URLComponents(string:  Constants.baseUrl + appendingString)!
    urlComponents.queryItems = queryItems
    
    guard let url = urlComponents.url else {
        return nil
    }
    var generatedRequest: URLRequest = .init(url: url)
    generatedRequest.httpMethod = HTTPMethod.get.rawValue
    generatedRequest.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerApiKey)
    
    return generatedRequest
}
