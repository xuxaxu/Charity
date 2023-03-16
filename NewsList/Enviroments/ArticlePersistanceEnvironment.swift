import Foundation

#if DEBUG
var CurrentPersistance = ArticlesPersistanceEnvironment.mock
#else
let CurrentPersistance = ArticlesPersistanceEnvironment.live
#endif

struct ArticlesPersistanceEnvironment {
    var fileClient: FileClient
}

extension ArticlesPersistanceEnvironment {
    static let live = ArticlesPersistanceEnvironment(fileClient: .live)
    static let mock = ArticlesPersistanceEnvironment(fileClient: .mock)
}

struct FileClient {
    var save: (String, Data) -> Effect<Never>
    var load: (String) -> Effect<Data?>
}

extension FileClient {
    static let live = Self(save: { fileName, data in
        Effect<Never> { _ in
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true)[0]
            let docURL = URL(fileURLWithPath: docPath)
            let articlePersistaneURL = docURL.appendingPathComponent(fileName)
            return try! data.write(to: articlePersistaneURL)
        }
    },
                           load: { filetName in
        Effect<Data?> { callback in
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true)[0]
            let docURL = URL(fileURLWithPath: docPath)
            let articlePersistanceURL = docURL.appendingPathComponent(filetName)
            if let data = try? Data(contentsOf: articlePersistanceURL) {
                callback(data)
            }
        }
    })
    static let mock = Self(save: {_,_ in Effect<Never>{ _ in}},
                           load: {_ in Effect<Data?>{ _ in}})
}
