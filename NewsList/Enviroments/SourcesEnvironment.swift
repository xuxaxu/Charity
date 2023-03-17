import Foundation

#if DEBUG
var CurrentSurces = SourcesEnvironment.live //.mock
#else
let CurrentSources = SourcesEnvironment.live
#endif

struct SourcesEnvironment {
    var restClient: RestClient
    
    var urlRequest: URLRequest?
    
    var parseNetworkSources: (Effect<Data?>) -> Effect<[NetworkSource]>
    
    var getSources: (Effect<[NetworkSource]>) -> Effect<[Source]>
    
    public func load() -> Effect<[Source]> {
        guard let urlRequest else {
            return Effect{ callback in
                callback([])
            }
        }
        return getSources(parseNetworkSources(loadDataEffect(restClient.request(urlRequest).recieve(on: .global())))).recieve(on: .main)
    }
}

extension SourcesEnvironment {
    static let live = SourcesEnvironment(restClient: .live,
                                         urlRequest: getSourcesRequest,
                                         parseNetworkSources: parseNetworkSource,
                                         getSources: getSourceFromNetworkSource)
    static let mock = SourcesEnvironment(restClient: .mock,
                                         urlRequest: nil,
                                         parseNetworkSources: {_ in Effect{_ in}},
                                         getSources:  {_ in Effect{_ in}})
}

let parseNetworkSource: (Effect<Data?>) -> Effect<[NetworkSource]> = { dataEffect in
    dataEffect.map({ ($0 == nil) ? [NetworkSource]() : (try? JSONDecoder().decode(NetworkSources.self, from: $0!).sources) ?? []})
}

let getSourceFromNetworkSource: (Effect<[NetworkSource]>) -> Effect<[Source]> = { effectNet in
    effectNet.map{ $0.compactMap{ Source($0) } }
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
