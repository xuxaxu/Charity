import XCTest
@testable import NewsList

final class NewsListTests: XCTestCase {

    override func setUpWithError() throws {
        try? super.setUpWithError()
        Current = .mock
    }

    func testItemsActionClear() {
        var state: [Article] = []
        state.append(Article(id: UUID(),
                             url: nil,
                             source: "source",
                             title: "title",
                             text: "text",
                             date: Date(timeIntervalSince1970: 1000)))
        let effects = itemsReducer(state: &state, action: .clear)
        XCTAssertTrue(state.isEmpty)
        XCTAssertTrue(effects.isEmpty)
    }
    
    func testItemsActionAdd() {
        var state: [Article] = []
        let article1 = Article(id: UUID(),
                             url: nil,
                             source: "source",
                             title: "title",
                             text: "text",
                             date: Date(timeIntervalSince1970: 1000))
        state.append(article1)
        let article2 = Article(id: UUID(),
                              url: nil,
                              source: "source2",
                              title: "title2",
                              text: "text text 2",
                              date: Date(timeIntervalSince1970: 2000))
        let effects = itemsReducer(state: &state, action: .addItem(article2))
        XCTAssertEqual(state.count, 2)
        XCTAssertEqual(state.first?.text, article1.text)
        XCTAssertEqual(state.last?.text, article2.text)
        XCTAssertTrue(effects.isEmpty)
    }
    
    func testItemsActionSet() {
        var state: [Article] = []
        let urlToImage = URL(string: "urlToImage1")
        let article1 = Article(id: UUID(),
                               url: nil,
                               source: "source",
                               title: "title",
                               text: "text",
                               date: Date(timeIntervalSince1970: 1000),
                               urlToImage: urlToImage)
        let article2 = Article(id: UUID(),
                               url: nil,
                               source: "source2",
                               title: "title2",
                               text: "text text 2",
                               date: Date(timeIntervalSince1970: 2000),
                               urlToImage: URL(string: "urlToImage2"))
        let effects = itemsReducer(state: &state, action: .set([article1, article2]))
        
        XCTAssertEqual(state.count, 2)
        XCTAssertEqual(state.first?.id, article1.id)
        XCTAssertEqual(state.last?.date, article2.date)
        XCTAssertEqual(effects.count, 2)
        
    }
    
    func testImagesActionAddImage() {
        var state: [Article] = []
        let urlToImage = URL(string: "urlToImage1")!
        let article1 = Article(id: UUID(),
                               url: nil,
                               source: "source",
                               title: "title",
                               text: "text",
                               date: Date(timeIntervalSince1970: 1000),
                               urlToImage: urlToImage)
        state.append(article1)
        let image = UIImage(systemName: "star")!
        let effects = imageReducer(state: &state, action: .addImage(urlToImage, image))
        
        XCTAssertEqual(state.count, 1)
        XCTAssertEqual(state.first?.id, article1.id)
        XCTAssertEqual(state.first?.image, image)
        
        XCTAssertTrue(effects.isEmpty)
    }
}
