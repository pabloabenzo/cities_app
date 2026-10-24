import Foundation

actor CitiesService {
    static let shared = CitiesService()
    
    private init() {}
    
    func fetchCities(from url: URL) async throws -> [CityModel] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let dtos = try JSONDecoder().decode([CitiesDTO].self, from: data)
        return dtos.map { dto in
            CityModel(
                id: dto._id,
                name: dto.name,
                country: dto.country,
                latitude: dto.coord.lat,
                longitude: dto.coord.lon
            )
        }
    }
}
