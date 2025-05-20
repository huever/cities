//
//  CityItem.swift
//  UalaTest
//
//  Created by Luciano Putignano on 20/05/2025.
//

import SwiftData
import Foundation

@Model
class CityItem {
    var country: String
    var name: String
    @Attribute(.unique) var id: Int
    var lat: Double
    var lon: Double
    var isFavorite: Bool = false

    init(
        country: String,
        name: String,
        id: Int,
        lat: Double,
        lon: Double,
        isFavorite: Bool = false
    ) {
        self.country = country
        self.name = name
        self.id = id
        self.lat = lat
        self.lon = lon
        self.isFavorite = isFavorite
    }
}
