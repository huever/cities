//
//  City.swift
//  UalaTest
//
//  Created by Luciano Putignano on 17/05/2025.
//

import Foundation

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}

struct City: Codable {
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
}
