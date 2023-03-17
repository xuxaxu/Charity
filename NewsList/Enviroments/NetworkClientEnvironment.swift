import Foundation
import UIKit

#if DEBUG
var CurrentNetworkClient = NetworkClientEnvironment.live //.mock
#else
let CurrentNetworkClient = NetworkClientEnvironment.live
#endif

struct NetworkClientEnvironment {
    var restClient: RestClient
    
    public func loadData(request: URLRequest) -> Effect<Data?> {
        restClient.request(request)
            .map(restClient.getData)
            .recieve(on: .global())
    }
    
    public func loadImage(url: URL) -> Effect<UIImage?> {
        let dataEffect = restClient.loadData(url).recieve(on: .global())
        let imageEffect = restClient.loadImage(dataEffect).recieve(on: .main)
        return imageEffect
    }
}

extension NetworkClientEnvironment {
    static let live = NetworkClientEnvironment(restClient: .live)
    static let mock = NetworkClientEnvironment(restClient: .mock)
}

public struct RestClient {
    var loadData: (URL) -> Effect<(Data?, URLResponse?, Error?)>
    var request: (URLRequest) -> Effect<(Data?, URLResponse?, Error?)>
    var loadImage: (Effect<(Data?, URLResponse?, Error?)>) -> Effect<UIImage?>
    var getData: (Data?, URLResponse?, Error?) -> Data?
}

extension RestClient {
    static let live = Self(loadData: dataTask,
                           request: urlRequestEffect,
                           loadImage: loadImageEffect,
                           getData: dataMap)
    static let mock = Self(loadData: {_ in Effect{ _ in} },
                           request: {_ in Effect{ _ in}},
                           loadImage: {_ in Effect{ _ in} },
                           getData: {_,_,_ in nil})
}

fileprivate let dataTask: (URL) -> Effect<(Data?, URLResponse?, Error?)> = { url in
    Effect { callback in
        URLSession.shared.dataTask(with: url) { data, response, error in
            callback((data, response, error))
        }
        .resume()
    }
}

fileprivate let urlRequestEffect: (URLRequest) -> Effect<(Data?, URLResponse?, Error?)> = { request in
    Effect { callback in
        URLSession.shared.dataTask(with: request) { data, response, error in
            callback((data, response, error))
        }
        .resume()
    }
}

fileprivate let loadImageEffect: (Effect<(Data?, URLResponse?, Error?)>) -> Effect<UIImage?> = { dataEffect in
    let effect: Effect<UIImage?> = dataEffect.map { $0.0 == nil ? nil : UIImage(data: $0.0!) }
    return effect
}

fileprivate let dataMap: (Data?, URLResponse?, Error?) -> Data? = { data, _, _ in
    data
}
