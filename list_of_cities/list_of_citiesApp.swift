//
//  list_of_citiesApp.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 11/02/2025.
//

import SwiftUI
import SwiftData

@main
struct list_of_citiesApp: App {
    var body: some Scene {
        WindowGroup {
            CitiesView()
        }
        .modelContainer(for: FavoriteCity.self)
    }
}
