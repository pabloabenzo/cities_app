import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Here you will find information about the selected city as soon as it is added to the received JSON.")
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "x.circle")
                                .tint(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
        }
    }
}
