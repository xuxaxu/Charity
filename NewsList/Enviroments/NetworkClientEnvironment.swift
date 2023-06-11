import Foundation
import UIKit
import ComposableArchitecture
import Combine

struct NetworkClientEnvironment {
    
    @Dependency(\.restClient) var restClient
    
    public func loadData(request: URLRequest) async throws -> Data {
        try await restClient.request(request).data
    }
    
    public func loadImage(url: URL) async -> UIImage? {
        do {
            let dataResponse = try await restClient.loadData(url)
            let image = restClient.loadImage(dataResponse.data, dataResponse.response)
            return image
        }
        catch {
            return nil
        }
    }
}

extension NetworkClientEnvironment: DependencyKey {
    static let liveValue: NetworkClientEnvironment = Self()
}

extension DependencyValues {
    var networkClient: NetworkClientEnvironment {
      get { self[NetworkClientEnvironment.self] }
      set { self[NetworkClientEnvironment.self] = newValue }
    }
}

public struct RestClient {
    var loadData: (URL) async throws -> (data: Data, response: URLResponse)
    var request: (URLRequest) async throws -> (data: Data, response: URLResponse)
    var loadImage: (Data, URLResponse) -> UIImage?
}

extension RestClient: DependencyKey {
    static public var liveValue: RestClient = Self(loadData: dataTask,
                                                   request: urlRequestEffect,
                                                   loadImage: loadImageEffect)
                           
    static let mock = Self(loadData: {_ in fatalError() },
                           request: {_ in fatalError() },
                           loadImage: {_,_ in nil })
}

extension DependencyValues {
    var restClient: RestClient {
        get { self[RestClient.self] }
        set { self[RestClient.self] = newValue }
    }
}

fileprivate let dataTask: (URL) async throws -> (data: Data, response: URLResponse) = { url in
    let (data, response) = try await URLSession.shared.data(from: url)
    return (data, response)
}

fileprivate let urlRequestEffect: (URLRequest) async throws -> (data: Data, response: URLResponse) = { request in
        let result = try await URLSession.shared.data(for: request)
        return result
}

fileprivate let loadImageEffect: (Data, URLResponse) -> UIImage? = { data, _  in
    UIImage(data: data)
}
