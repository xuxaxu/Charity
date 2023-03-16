import Foundation
import UIKit

#if DEBUG
var CurrentItemsWithImage = ItemsWithImageEnvironment.live //.mock
#else
let CurrentItemsWithImage = ItemsWithImageEnvironment.live
#endif

struct ItemsWithImageEnvironment {
    private var restClient: RestClient
    
    public func loadData(request: URLRequest) -> Effect<Data?> {
        loadDataEffect(restClient.request(request).recieve(on: .global()))
    }
    
    public func loadImage(url: URL) -> Effect<UIImage?> {
        let dataEffect = restClient.loadData(url).recieve(on: .global())
        let imageEffect = restClient.loadImage(dataEffect).recieve(on: .main)
        return imageEffect
    }
}

extension ItemsWithImageEnvironment {
    static let live = ItemsWithImageEnvironment(restClient: .live)
    static let mock = ItemsWithImageEnvironment(restClient: .mock)
}

public struct RestClient {
    var loadData: (URL) -> Effect<(Data?, URLResponse?, Error?)>
    var request: (URLRequest) -> Effect<(Data?, URLResponse?, Error?)>
    var loadImage: (Effect<(Data?, URLResponse?, Error?)>) -> Effect<UIImage?>
}

extension RestClient {
    static let live = Self(loadData: dataTask,
                           request: urlRequestEffect,
                           loadImage: loadImageEffect)
    static let mock = Self(loadData: {_ in Effect{ _ in} },
                           request: {_ in Effect{ _ in}},
                           loadImage: {_ in Effect{ _ in} })
}

public let dataTask: (URL) -> Effect<(Data?, URLResponse?, Error?)> = { url in
    Effect { callback in
        URLSession.shared.dataTask(with: url) { data, response, error in
            callback((data, response, error))
        }
        .resume()
    }
}

public let urlRequestEffect: (URLRequest) -> Effect<(Data?, URLResponse?, Error?)> = { request in
    Effect { callback in
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback((data, response, error))
        }
        .resume()
    }
}

public let loadImageEffect: (Effect<(Data?, URLResponse?, Error?)>) -> Effect<UIImage?> = { dataEffect in
    let effect: Effect<UIImage?> = dataEffect.map { $0.0 == nil ? nil : UIImage(data: $0.0!) }
    return effect
}

public let loadDataEffect: (Effect<(Data?, URLResponse?, Error?)>) -> Effect<Data?> = { dataEffect in
    let effect: Effect<Data?> = dataEffect.map { $0.0 == nil ? nil : $0.0! }
    return effect
}
