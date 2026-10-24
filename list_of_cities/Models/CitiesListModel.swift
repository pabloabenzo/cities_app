import Foundation

struct CitiesListModel {
    var allCities: [CityModel] = []
    var displayedCities: [CityModel] = []
    var filteredCities: [CityModel] = []
    var favoriteCityIds: Set<Int> = []
    var selectedCity: CityModel?
    var defaultCity: CityModel?
    var showingFavorites: Bool = false
    var searchText: String = ""
    var isLoading: Bool = false
}
