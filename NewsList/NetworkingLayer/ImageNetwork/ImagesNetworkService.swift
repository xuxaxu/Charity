import Foundation
import UIKit

public func dataTask(with request: URL) -> Effect<(Data?, URLResponse?, Error?)> {
    return Effect { callback in
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback((data, response, error))
        }
        .resume()
    }
}

func getImageEffect<Item: ItemWithImage>(url: URL) -> Effect<ImagesAction<Item>> {
    return dataTask(with: url).map { data, _, _ in
        guard let data else {
            return .empty
        }
        guard let image = UIImage(data: data) else {
            return .empty
        }
        return .addImage(url, image)
    }
}
