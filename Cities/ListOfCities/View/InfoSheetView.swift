//
//  InfoSheetView.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
//

import SwiftUI

struct InfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Here you'll find information about the selected city as soon as it's added to the received JSON.")
                    .padding()
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "x.circle")
                                .tint(.black)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InfoSheetView()
}
