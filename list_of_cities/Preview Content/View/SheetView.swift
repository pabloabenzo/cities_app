//
//  SheetView.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 11/02/2025.
//

import Foundation

import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Here you will find information about the selected city as soon as it is added to the received JSON.")
                    .padding()
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
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
