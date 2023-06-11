import Foundation
import ComposableArchitecture

struct ArticleNetworkEnvironment {
    @Dependency(\.restClient) var restClient
    
    var urlRequest: (String, Int) -> URLRequest?
    
    var parseNetworkArticles: (Data?) -> [NetworkArticle]
    
    var getArticles: ([NetworkArticle]) -> [Article]
    
    public func load(_ domains: String, _ page: Int) async throws -> [Article] {
        guard let request = urlRequest(domains, page) else {
            return []
        }
        return getArticles(parseNetworkArticles(try await restClient.request(request).data))
    }
}

extension ArticleNetworkEnvironment: DependencyKey {
    static var liveValue: ArticleNetworkEnvironment = ArticleNetworkEnvironment(urlRequest: getArticlesRequest,
                                                parseNetworkArticles: parseNetworkArticle,
                                                getArticles: getArticleFromNetworkArticle)
    static let mock = ArticleNetworkEnvironment(urlRequest: {_,_ in nil},
                                                parseNetworkArticles: {_ in []},
                                                getArticles:  {_ in []})
}

extension DependencyValues {
    var articleNetwork: ArticleNetworkEnvironment {
        get { self[ArticleNetworkEnvironment.self] }
        set { self[ArticleNetworkEnvironment.self] = newValue }
      }
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
    generatedRequest.httpMethod = "GET"
    generatedRequest.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerApiKey)
    
    return generatedRequest
}

struct ArticleNetworkParserImp {
    func parse(article: NetworkArticle) -> Article? {
        guard let title = article.title else {
            return nil
        }
        return Article(id: UUID(),
                       url: URL(string: article.url ?? ""),
                       source: article.source?.name,
                       title: title,
                       text: article.description,
                       date: Date() // article.publishedAt
        )
    }
}
