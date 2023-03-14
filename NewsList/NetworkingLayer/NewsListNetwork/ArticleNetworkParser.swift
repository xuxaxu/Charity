import Foundation

protocol ArticleNetworkParser {
    func parse(article: NetworkArticle) -> Article?
}

class ArticleNetworkParserImp: ArticleNetworkParser {
    func parse(article: NetworkArticle) -> Article? {
        guard let title = article.title else {
            return nil
        }
        let date = Date()
        let url = (article.url == nil) ? nil : URL(string: article.url!)
        let imageUrl = (article.urlToImage == nil) ? nil : URL(string: article.urlToImage!)
        let id = UUID()
        let articleDomain = Article(id: id,
                                    url: url,
                                    source: article.source?.name,
                                    title: title,
                                    text: article.description,
                                    image: nil,
                                    date: date,
                                    urlToImage: imageUrl)
        return articleDomain
    }
}
