//
//  CitiesModel.swift
//  list_of_cities
//
//  Created by Pablo Benzo on 11/02/2025.
//

import Foundation

struct CitiesInfo: Decodable, Hashable {
    var country: String
    var name: String
    var _id: Int
    var coord: Coord
    
    struct Coord: Decodable, Hashable {
        var lon: Double
        var lat: Double
    }
}
