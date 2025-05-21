//
//  APIManager.swift
//  UalaTest
//
//  Created by Luciano Putignano on 17/05/2025.
//

import Foundation
import SwiftData

class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
    
    internal init() {}
    
    func fetchCities() async throws -> [City] {

        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let cities = try decoder.decode([City].self, from: data)
        
        return cities
    }

    func deleteAllCities(context: ModelContext) {
        let descriptor = FetchDescriptor<CityItem>()
        if let allCities = try? context.fetch(descriptor) {
            for city in allCities {
                context.delete(city)
            }
            print("Todas las ciudades eliminadas.")
        }
    }
}

// Extensión para pruebas
extension APIManager {
#if DEBUG
    public convenience init(forTesting: Bool = false) {
        self.init()
    }
#endif
}
