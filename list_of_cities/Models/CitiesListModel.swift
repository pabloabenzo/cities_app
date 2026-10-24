import Foundation

struct CitiesListModel {
    var allCities: [CityModel] = []
    var filteredCities: [CityModel] = []
    var fullFilteredCities: [CityModel] = []
    var favoriteCityIds: Set<Int> = []
    var selectedCity: CityModel?
    var defaultCity: CityModel?
    var showingFavorites: Bool = false
    var searchText: String = ""
    var isLoading: Bool = false
    let initialPageSize: Int = 20
    let loadMoreSize: Int = 2
}
