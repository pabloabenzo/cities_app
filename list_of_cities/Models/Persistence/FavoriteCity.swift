import Foundation
import SwiftData

@Model
final class FavoriteCity {
    @Attribute(.unique) var cityId: Int
    var name: String
    var country: String
    
    init(cityId: Int, name: String, country: String) {
        self.cityId = cityId
        self.name = name
        self.country = country
    }
}
