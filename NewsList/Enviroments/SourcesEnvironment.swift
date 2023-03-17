import Foundation

#if DEBUG
var CurrentSurces = SourcesEnvironment.live //.mock
#else
let CurrentSources = SourcesEnvironment.live
#endif

struct SourcesEnvironment {
    var restClient: RestClient
    
    var urlRequest: URLRequest?
    
    var parseNetworkSources: (Data?) -> [NetworkSource]
    
    var getSources: ([NetworkSource]) -> [Source]
    
    public func load() -> Effect<[Source]> {
        guard let urlRequest else {
            return Effect{ callback in
                callback([])
            }
        }
        return restClient.request(urlRequest)
                .map(restClient.getData)
                .map(parseNetworkSources)
                .recieve(on: .global())
                .map(getSources)
                .recieve(on: .main)
    }
}

extension SourcesEnvironment {
    static let live = SourcesEnvironment(restClient: .live,
                                         urlRequest: getSourcesRequest,
                                         parseNetworkSources: parseNetworkSource,
                                         getSources: getSourceFromNetworkSource)
    static let mock = SourcesEnvironment(restClient: .mock,
                                         urlRequest: nil,
                                         parseNetworkSources: {_ in []},
                                         getSources:  {_ in []})
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
        generatedRequest.httpMethod = HTTPMethod.get.rawValue
        generatedRequest.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerApiKey)
        return generatedRequest
}()
