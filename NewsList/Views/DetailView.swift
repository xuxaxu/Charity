import SwiftUI

struct DetailView: View {
    typealias DetailViewState = Article
    
    @ObservedObject var store: Store<DetailViewState, AppAction<Article>>
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text(store.value.source ?? "")
                    .padding(DesignSizes.offset)
                    .foregroundColor(.gray)
            }
            HStack{
                Spacer()
                Text(store.value.date?.formatted(date: .long,
                                                 time: .omitted) ?? "")
                .padding(DesignSizes.offset)
                .font(.caption)
                
            }
            Text(store.value.title)
                .font(.headline)
                .padding(DesignSizes.offset)
            if let image = store.value.image {
                Image(uiImage: image).resizable()
                    .scaledToFit()
                    .cornerRadius(DesignSizes.cornerRadius)
            }
            Text(store.value.text ?? "")
                .padding()
                .padding(DesignSizes.offset)
            Spacer()
            Text(store.value.url?.absoluteString ?? "no link")
                .foregroundColor(.blue)
                .underline()
                .padding(DesignSizes.offset)
            Spacer()
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
        
        DetailView(store: Store(value: article,
                                reducer: {_,_ in
            return []
        }))
    }
}
