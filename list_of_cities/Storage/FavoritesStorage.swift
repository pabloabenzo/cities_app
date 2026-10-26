import Foundation
import SwiftData

@MainActor
final class FavoritesStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        let schema = Schema([FavoriteCity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    func fetchFavoriteIds() -> Set<Int> {
        do {
            let favorites = try modelContext.fetch(FetchDescriptor<FavoriteCity>())
            return Set(favorites.map { $0.cityId })
        } catch {
            return []
        }
    }
    
    func addFavorite(city: CityModel) {
        let favorite = FavoriteCity(cityId: city.id, name: city.name, country: city.country)
        modelContext.insert(favorite)
        save()
    }
    
    func removeFavorite(cityId: Int) {
        do {
            let descriptor = FetchDescriptor<FavoriteCity>(predicate: #Predicate { $0.cityId == cityId })
            let favorites = try modelContext.fetch(descriptor)
            for favorite in favorites {
                modelContext.delete(favorite)
            }
            save()
        } catch {
            return
        }
    }
    
    func isFavorite(cityId: Int) -> Bool {
        do {
            let descriptor = FetchDescriptor<FavoriteCity>(predicate: #Predicate { $0.cityId == cityId })
            let favorites = try modelContext.fetch(descriptor)
            return !favorites.isEmpty
        } catch {
            return false
        }
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            return
        }
    }
}
