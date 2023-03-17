import SwiftUI

struct SourceView: View {
    @ObservedObject var store: Store<Source, FlagAction>
    var body: some View {
        HStack {
            HStack(alignment: .top) {
                Text(store.value.name)
                    .font(.headline)
                    .layoutPriority(1)
                VStack(alignment: .leading) {
                    Text(store.value.category ?? "")
                    Text(store.value.language ?? "")
                    Text(store.value.country ?? "")
                }
                .font(.caption)
                .layoutPriority(1)
            }
            //.padding(DesignSizes.bigOffset)
            Spacer()
            FlagView(store: store.view(value: { $0.include },
                                       action: { $0}))
        }
        .padding(DesignSizes.offset)
    }
}

struct SourceView_Previews: PreviewProvider {
    static var previews: some View {
        let netSource = NetworkSource(id: "123",
                                      name: "bbc news",
                                      description: "good news every day",
                                      category: "common",
                                      language: "eng",
                                      country: "gb")
        let source = Source(netSource)
        SourceView(store: Store(value: source,
                                reducer: {_, _ in []}))
    }
}
