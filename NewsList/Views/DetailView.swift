import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    
    let store: StoreOf<ArticleFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            VStack {
                HStack{
                    Spacer()
                    Text(viewStore.article.source ?? "")
                        .padding(DesignSizes.offset)
                        .foregroundColor(.gray)
                }
                HStack{
                    Spacer()
                    Text(viewStore.article.date?.formatted(date: .long,
                                                     time: .omitted) ?? "")
                    .padding(DesignSizes.offset)
                    .font(.caption)
                    
                }
                Text(viewStore.article.title)
                    .font(.headline)
                    .padding(DesignSizes.offset)
                if let image = viewStore.article.image {
                    Image(uiImage: image).resizable()
                        .scaledToFit()
                        .cornerRadius(DesignSizes.cornerRadius)
                }
                Text(viewStore.article.text ?? "")
                    .padding()
                    .padding(DesignSizes.offset)
                Spacer()
                Text(viewStore.article.url?.absoluteString ?? "no link")
                    .foregroundColor(.blue)
                    .underline()
                    .padding(DesignSizes.offset)
                Spacer()
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let article = Article(id: UUID(),
                                       url: nil,
                                       source: "tech.com",
                                       title: "title",
                                       text: "some long text",
                                       image: nil,
                                       date: Date(),
                                       urlToImage: nil)
        let state = ArticleFeature.State(article: article)
        
        DetailView(store: Store(initialState: state, reducer: ArticleFeature()))
    }
}

struct ArticleFeature: ReducerProtocol {
    struct State: Equatable {
        var article: Article
    }
    enum Action {
    }
    func reduce(into state: inout State,
                action: Action) -> EffectTask<Action> {
        return .none
    }
}
