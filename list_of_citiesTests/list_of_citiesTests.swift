import Testing
@testable import list_of_cities

@Suite("Cities Tests")
struct CitiesTests {
    
    @Test("Map DTO to CityModel")
    func mapDTOToCityModel() throws {
        let dto = CitiesDTO(
            country: "UA",
            name: "Hurzuf",
            _id: 707860,
            coord: CitiesDTO.CoordDTO(lon: 34.283333, lat: 44.549999)
        )
        
        let model = CityModel(
            id: dto._id,
            name: dto.name,
            country: dto.country,
            latitude: dto.coord.lat,
            longitude: dto.coord.lon
        )
        
        #expect(model.id == 707860)
        #expect(model.name == "Hurzuf")
        #expect(model.country == "UA")
        #expect(model.latitude == 44.549999)
        #expect(model.longitude == 34.283333)
    }
    
    @Test("Decode cities DTO array")
    func decodeCitiesDTOArray() throws {
        let jsonString = """
        [
            {
                "country":"UA",
                "name":"Hurzuf",
                "_id":707860,
                "coord":{"lon":34.283333,"lat":44.549999}
            }
        ]
        """
        let data = try #require(jsonString.data(using: .utf8))
        let dtos = try JSONDecoder().decode([CitiesDTO].self, from: data)
        #expect(dtos.count == 1)
        #expect(dtos.first?.name == "Hurzuf")
        #expect(dtos.first?._id == 707860)
    }
    
    @MainActor
    @Test("Toggle favorite updates model and filtering")
    func toggleFavoriteUpdatesModel() async {
        let presenter = CitiesPresenter()
        let city = CityModel(id: 123, name: "TestCity", country: "TC", latitude: 0, longitude: 0)
        presenter.model.allCities = [city]
        presenter.model.filteredCities = [city]
        
        #expect(presenter.isFavorite(city) == false)
        await presenter.action(.toggleFavorite(city))
        #expect(presenter.isFavorite(city) == true)
        await presenter.action(.toggleFavorite(city))
        #expect(presenter.isFavorite(city) == false)
    }
    
    @MainActor
    @Test("Toggle favorites filter shows only favorites")
    func toggleFavoritesFilter() async {
        let presenter = CitiesPresenter()
        let favCity = CityModel(id: 1, name: "Fav", country: "F", latitude: 0, longitude: 0)
        let otherCity = CityModel(id: 2, name: "Other", country: "O", latitude: 0, longitude: 0)
        presenter.model.allCities = [favCity, otherCity]
        presenter.model.favoriteCityIds = [1]
        presenter.model.filteredCities = [favCity, otherCity]
        
        await presenter.action(.toggleFavoritesFilter)
        #expect(presenter.model.showingFavorites == true)
        #expect(presenter.model.filteredCities.count == 1)
        #expect(presenter.model.filteredCities.first?.id == 1)
        
        await presenter.action(.toggleFavoritesFilter)
        #expect(presenter.model.showingFavorites == false)
        #expect(presenter.model.filteredCities.count == 2)
    }
    
    @MainActor
    @Test("Search filters by prefix")
    func searchFiltersByPrefix() async {
        let presenter = CitiesPresenter()
        let hurzuf = CityModel(id: 1, name: "Hurzuf", country: "UA", latitude: 0, longitude: 0)
        let madrid = CityModel(id: 2, name: "Madrid", country: "ES", latitude: 0, longitude: 0)
        presenter.model.allCities = [hurzuf, madrid]
        presenter.model.filteredCities = [hurzuf, madrid]
        
        await presenter.action(.search("Hur"))
        #expect(presenter.model.filteredCities.count == 1)
        #expect(presenter.model.filteredCities.first?.name == "Hurzuf")
        
        await presenter.action(.search(""))
        #expect(presenter.model.filteredCities.count == 2)
    }
    
    @MainActor
    @Test("Select city updates model")
    func selectCityUpdatesModel() async {
        let presenter = CitiesPresenter()
        let city = CityModel(id: 10, name: "Test", country: "T", latitude: 1, longitude: 2)
        await presenter.action(.selectCity(city))
        #expect(presenter.model.selectedCity?.id == 10)
        await presenter.action(.selectCity(nil))
        #expect(presenter.model.selectedCity == nil)
    }
}
