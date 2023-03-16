import Foundation

protocol NewsListNetworkService: AnyObject {
    func getNews(
        page: Int,
        completion: @escaping (Result<NetworkModel, Error>) -> Void
    )
}

final class NewsListNetworkServiceImp: NewsListNetworkService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getNews(
        page: Int,
        completion: @escaping (Result<NetworkModel, Error>) -> Void
    ) {
        guard let request = try? createNewsListRequest(page: page)
        else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }

        networkClient.processRequest(request: request, completion: completion)
    }
    
    func getNews(page: Int) -> Effect<(Result<NetworkModel, Error>)> {
        guard let request = try? createNewsListRequest(page: page) else {
            return Effect { _ in }
        }
        return Effect { [weak self] callback in
            self?.networkClient.processRequest(request: request) { result in
                callback(result)
            }
        }
    }

    private func createNewsListRequest(page: Int) throws -> HTTPRequest {
        
        let appendingUrlString = "/everything"
        let headers = ["X-Api-Key": Constants.apiKey]
        let params: [HTTPRequestQueryItem] = [("pageSize", String(Constants.pageSize)),
                                              ("domains", Constants.domains),
                                               ("page", String(page))]
        
        return HTTPRequest(
            route: Constants.baseUrl + appendingUrlString,
            headers: headers,
            queryItems: params,
            httpMethod: .get
        )
    }
}

let getSourcesRequest: Effect<URLRequest?> = {
    Effect {callback in
        let appendingString = "/top-headlines/sources"
        
        guard let url = URL(string: Constants.baseUrl + appendingString) else {
            callback(nil)
            return
        }
        var generatedRequest: URLRequest = .init(url: url)
        generatedRequest.httpMethod = HTTPMethod.get.rawValue
        generatedRequest.addValue(Constants.apiKey, forHTTPHeaderField: Constants.headerApiKey)
        callback(generatedRequest)
    }
}()
