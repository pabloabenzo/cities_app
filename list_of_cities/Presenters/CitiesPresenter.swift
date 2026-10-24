import Foundation
import SwiftUI

@MainActor
@Observable
class CitiesPresenter {
    var model = CitiesListModel()
    
    private let service = CitiesService.shared
    private let favoritesKey = "fav_key"
    private let citiesURL = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")
    
    init() {
        model.favoriteCityIds = loadFavorites()
    }
    
    enum Action {
        case loadCities
        case search(String)
        case toggleFavorite(CityModel)
        case toggleFavoritesFilter
        case selectCity(CityModel?)
        case setDefaultCity(CityModel?)
    }
    
    func action(_ action: Action) async {
        switch action {
        case .loadCities:
            await loadCities()
        case .search(let text):
            search(text)
        case .toggleFavorite(let city):
            toggleFavorite(city)
        case .toggleFavoritesFilter:
            toggleFavoritesFilter()
        case .selectCity(let city):
            model.selectedCity = city
        case .setDefaultCity(let city):
            model.defaultCity = city
        }
    }
    
    private func loadCities() async {
        guard let url = citiesURL else { return }
        model.isLoading = true
        do {
            let cities = try await service.fetchCities(from: url)
            model.allCities = cities.sorted { $0.name < $1.name }
            applyFilters()
        } catch {
            print("data inválida")
        }
        model.isLoading = false
    }
    
    private func search(_ text: String) {
        model.searchText = text
        applyFilters()
    }
    
    private func toggleFavorite(_ city: CityModel) {
        if model.favoriteCityIds.contains(city.id) {
            model.favoriteCityIds.remove(city.id)
        } else {
            model.favoriteCityIds.insert(city.id)
        }
        saveFavorites()
        applyFilters()
    }
    
    private func toggleFavoritesFilter() {
        model.showingFavorites.toggle()
        applyFilters()
    }
    
    func isFavorite(_ city: CityModel) -> Bool {
        model.favoriteCityIds.contains(city.id)
    }
    
    private func applyFilters() {
        var result: [CityModel] = []
        if model.showingFavorites {
            result = model.allCities.filter { model.favoriteCityIds.contains($0.id) }
        } else {
            result = model.allCities
        }
        
        if !model.searchText.isEmpty {
            result = result.filter {
                $0.name.lowercased().hasPrefix(model.searchText.lowercased())
            }
        }
        
        model.fullFilteredCities = result
        model.filteredCities = Array(result.prefix(model.initialPageSize))
    }
    
    private func loadFavorites() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] ?? [Int]()
        return Set(array)
    }
    
    private func saveFavorites() {
        let array = Array(model.favoriteCityIds)
        UserDefaults.standard.set(array, forKey: favoritesKey)
    }
}
