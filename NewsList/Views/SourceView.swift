import SwiftUI
import ComposableArchitecture

struct SourceView: View {
    let store: StoreOf<SourceFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                HStack(alignment: .top) {
                    Text( viewStore.source.name)
                        .font(.headline)
                        .layoutPriority(1)
                    VStack(alignment: .leading) {
                        Text(viewStore.source.category ?? "")
                        Text(viewStore.source.language ?? "")
                        Text(viewStore.source.country ?? "")
                    }
                    .font(.caption)
                    .layoutPriority(1)
                }
                Spacer()
                FlagView(store: Store(initialState: FlagFeature.State(flag: viewStore.on), reducer: FlagFeature()))
            }
            .padding(DesignSizes.offset)
        }
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
        let source =  Source(netSource)
        let state = SourceFeature.State(source: source,
                                        on: false)
        SourceView(store:  Store(initialState: state,
                                 reducer: SourceFeature(),
                                 prepareDependencies: { _ in }))
    }
}
