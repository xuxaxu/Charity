import Foundation
import ComposableArchitecture

struct AppEnvironment {
    var uuid: () -> UUID
    @Dependency(\.sources) var getSourcesEnvironment: SourcesEnvironment
    @Dependency(\.articleNetwork) var getArticlesEnvironment: ArticleNetworkEnvironment
    @Dependency(\.fileClient) var persistanceEnvironment: FileClient
}

extension AppEnvironment: DependencyKey {
  static let liveValue = Self(uuid: { UUID() })
}

extension DependencyValues {
  var appEnvironment: AppEnvironment {
    get { self[AppEnvironment.self] }
    set { self[AppEnvironment.self] = newValue }
  }
}
