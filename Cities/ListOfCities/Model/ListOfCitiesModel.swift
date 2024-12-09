//
//  ListOfCitiesModel.swift
//  Cities
//
//  Created by Pablo Benzo on 20/11/2024.
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
