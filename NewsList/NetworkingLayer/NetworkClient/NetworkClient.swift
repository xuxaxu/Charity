import Foundation

protocol NetworkClient {
    @discardableResult
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Cancellable?
    func rawDataRequest(request: URLRequest,
                      completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}
