import SwiftUI
import ComposableArchitecture

struct FlagView: View {
    let flag: Bool
    var body: some View {
        VStack {
            flag ?
            Label("", systemImage: "checkmark.circle")
                .foregroundColor(.green) :
            Label("", systemImage: "circle")
            .foregroundColor(.gray)
        }
    }
}

struct FlagView_Previews: PreviewProvider {
    static var previews: some View {
        FlagView(flag: false)
    }
}
