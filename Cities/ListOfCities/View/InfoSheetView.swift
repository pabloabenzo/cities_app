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
                Text("Aqui encontrarás informacion de la ciudad seleccionada en cuanto la misma se agregue en el JSON recibido.")
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
