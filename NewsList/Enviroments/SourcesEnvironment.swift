import Foundation
import ComposableArchitecture

struct SourcesEnvironment {
    @Dependency(\.restClient) var restClient
    
    var urlRequest: URLRequest?
    
    var parseNetworkSources: (Data?) -> [NetworkSource]
    
    var getSources: ([NetworkSource]) -> [Source]
    
    public func load() async throws -> [Source] {
        guard let urlRequest else {
            return []
        }
        return getSources(parseNetworkSources(try await restClient.request(urlRequest).data))
    }
}

extension SourcesEnvironment: DependencyKey {
    static var liveValue: SourcesEnvironment = Self(urlRequest: getSourcesRequest,
                                                    parseNetworkSources: parseNetworkSource,
                                                    getSources: getSourceFromNetworkSource)
    
    static let mock = SourcesEnvironment(parseNetworkSources: {_ in []},
                                         getSources:  {_ in []})
}

extension DependencyValues {
    var sources: SourcesEnvironment {
      get { self[SourcesEnvironment.self] }
      set { self[SourcesEnvironment.self] = newValue }
    }
}

let parseNetworkSource: (Data?) -> [NetworkSource] = { data in
    guard let data else {
        return []
    }
    guard let sources = try? JSONDecoder().decode(NetworkSources.self, from: data).sources else {
        return []
    }
    return sources
}

let getSourceFromNetworkSource: ([NetworkSource]) -> [Source] = { netSources in
    netSources.compactMap{ Source($0) }
}

let getSourcesRequest: URLRequest? = {
        let appendingString = "/top-headlines/sources"
        
        guard let url = URL(string: Constants.baseUrl + appendingString) else {
            return nil
        }
        var generatedRequest: URLRequest = .init(url: url)
        generatedRequest.httpMethod = "GET"
        generatedRequest.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerApiKey)
        return generatedRequest
}()
