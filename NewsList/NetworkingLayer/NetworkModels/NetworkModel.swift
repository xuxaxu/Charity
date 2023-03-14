struct NetworkModel: Decodable {
    let articles: [NetworkArticle]
    let totalResults: Int?
}

struct NetworkArticle: Decodable {
    let source: NetworkSource?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
}

struct NetworkSource: Decodable {
    let name: String
}
