//
//  CitiesViewModel.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 11/02/2025.
//

import Foundation
import SwiftUI
import Observation

@Observable
class CitiesViewModel: ObservableObject, Sendable {
    
    var initialCitiesLoaded: [CitiesInfo] = []
    private var showingFavs = false
    private var savedItems: Set<Int> = [1, 7]
    var listResults = [CitiesInfo]()
    var defaultCity: CitiesInfo?
    var selectedCity: CitiesInfo?
    
    let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
    
    func fetchData(from url: URL, completion: ((Result<Data, any Error>) -> Void)? = nil) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([CitiesInfo].self, from: data) {
                let results = decodedResponse
                
                DispatchQueue.main.async {
                    self.listResults = results.sorted { $0.name < $1.name }
                }
            }
        } catch {
            print("data inválida")
        }
    }
    
    func save(items: Set<Int>) {
        let array = Array(items)
        UserDefaults.standard.set(array, forKey: "fav_key")
    }
    
    func load() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: "fav_key") as? [Int] ?? [Int]()
        return Set(array)
    }
    
    // Saved items filter.
    var filteredItems: [CitiesInfo]  {
        if showingFavs {
            return initialCitiesLoaded.filter { savedItems.contains($0._id) }
        }
        return initialCitiesLoaded
    }
        
    init() {
        self.savedItems = load()
    }
    
    func sortFavs() {
        withAnimation() {
            showingFavs.toggle()
        }
    }
    
    func contains(_ item: CitiesInfo) -> Bool {
            savedItems.contains(item._id)
        }
    
    func toggleFav(item: CitiesInfo) {
        if contains(item) {
            savedItems.remove(item._id)
        } else {
            savedItems.insert(item._id)
        }
        save(items: savedItems)
    }
}
