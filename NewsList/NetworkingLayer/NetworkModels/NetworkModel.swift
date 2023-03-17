struct NetworkModel: Decodable {
    let articles: [NetworkArticle]
    let totalResults: Int?
}

struct NetworkArticle: Decodable {
    let source: NetworkArticleSource?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
}

struct NetworkArticleSource: Decodable {
    let name: String
}

struct NetworkSources: Decodable {
    let status: String
    let sources: [NetworkSource]
}

struct NetworkSource: Decodable {
    let id: String?
    let name: String?
    let description: String?
    let category: String?
    let language: String?
    let country: String?
}
