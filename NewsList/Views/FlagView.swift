import SwiftUI

struct FlagView: View {
    @ObservedObject var store: Store<Bool, FlagAction>
    var body: some View {
        VStack {
            Button(action: { store.send( store.value ? .off : .on)},
                   label: { store.value ?
                Label("", systemImage: "checkmark.circle")
                    .foregroundColor(.green) :
                Label("", systemImage: "circle")
                .foregroundColor(.gray) })
        }
    }
}

struct FlagView_Previews: PreviewProvider {
    static var previews: some View {
        FlagView(store: Store(value: false,
                              reducer: {_,_  in [Effect<FlagAction>{_ in}]}))
    }
}
