import Foundation

struct CitiesDTO: Decodable {
    let country: String
    let name: String
    let _id: Int
    let coord: CoordDTO
    
    struct CoordDTO: Decodable {
        let lon: Double
        let lat: Double
    }
}
