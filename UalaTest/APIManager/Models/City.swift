//
//  City.swift
//  UalaTest
//
//  Created by Luciano Putignano on 17/05/2025.
//

import Foundation
import MapKit

struct Coordinate: Codable, Hashable {
    let lon: Double
    let lat: Double
}

struct City: Codable, Hashable, Identifiable {
    let country: String
    let name: String
    let id: Int
    let coord: Coordinate

    enum CodingKeys: String, CodingKey {
        case country
        case name
        case id = "_id"
        case coord
    }

    func getCoord() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
    }

    init(country: String, name: String, id: Int, coord: Coordinate) {
        self.country = country
        self.name = name
        self.id = id
        self.coord = coord
    }

    init(from cityItem: CityItem) {
        id = cityItem.id
        name = cityItem.name
        country = cityItem.country
        coord = Coordinate(lon: cityItem.lon, lat: cityItem.lat)
    }

    static func defaultCity() -> City {
        .init(country: "AR", name: "Mendoza", id: 1, coord: Coordinate(lon: -68.844576, lat: -32.889698))
    }
}
