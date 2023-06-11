import Foundation
import ComposableArchitecture

struct FileClient {
    var save: (String, Data) -> ()
    var load: (String) -> Data?
}

extension FileClient: DependencyKey {
    static let liveValue: FileClient = Self(save: { fileName, data in
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true)[0]
            let docURL = URL(fileURLWithPath: docPath)
            let articlePersistaneURL = docURL.appendingPathComponent(fileName)
        do {
            try data.write(to: articlePersistaneURL)
        } catch {
            return
        }
    },
                           load: { fileName in
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .userDomainMask,
                                                              true)[0]
            let docURL = URL(fileURLWithPath: docPath)
            let articlePersistanceURL = docURL.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: articlePersistanceURL)
            return data
        } catch {
            return nil
        }
    })
    static let mock = Self(save: {_,_ in },
                           load: {_ in nil})
}

extension DependencyValues {
    var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
}
