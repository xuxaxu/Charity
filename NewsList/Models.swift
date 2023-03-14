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
