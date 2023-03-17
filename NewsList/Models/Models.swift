import Foundation
import UIKit.UIImage

protocol ItemWithImage: Equatable {
    var image: UIImage? { get set }
    var urlToImage: URL? { get }
}

struct Article: Identifiable, ItemWithImage, Equatable {
    var id: UUID
    let url: URL?
    let source: String?
    let title: String
    let text: String?
    var image: UIImage?
    let date: Date?
    var urlToImage: URL?
}

struct Activity {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
        case openDetail(URL)
        case openURL(URL)
    }
}

struct NewsListItem: Identifiable {
    let id: UUID
    let title: String
    let image: UIImage?
    let detailed: Int
    
    init(from article: Article, detailed: Int) {
        self.id = article.id
        self.title = article.title
        self.image = article.image
        self.detailed = detailed
    }
}

struct Source: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: String?
    let language: String?
    let country: String?
    let include: Bool
    init(_ source: NetworkSource) {
        self.id = UUID(uuidString: source.id ?? "") ?? UUID()
        self.name = source.name ?? self.id.uuidString
        self.category = source.category
        self.language = source.language
        self.country = source.country
        self.include = false
    }
    init(_ source: Source, include: Bool) {
        self.country = source.country
        self.language = source.language
        self.category = source.category
        self.id = source.id
        self.name = source.name
        self.include = include
    }
}
