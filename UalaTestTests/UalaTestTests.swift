//
//  UalaTestTests.swift
//  UalaTestTests
//
//  Created by Luciano Putignano on 15/05/2025.
//

import Testing
import XCTest
import SwiftData
@testable import UalaTest

@MainActor
final class CitiesListViewModelTests: XCTestCase {

    var viewModel: CitiesListViewModel!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let container = try! ModelContainer(for: CityItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        context = ModelContext(container)

        viewModel = CitiesListViewModel()
        viewModel.setContext(context)
    }

    func testFetchDataSearchMFilter() {
        // Arrange: insert test data
        _ = makeCity(name: "Buenos Aires", id: 1)
        _ = makeCity(name: "Mendoza", id: 2)
        _ = makeCity(name: "Mar del Plata", id: 3)

        try? context.save()

        // Act: buscar "M" debería traer Mendoza y Mar del Plata
        viewModel.searchText = "M"
        viewModel.fetchData(reset: true)

        // Assert
        XCTAssertEqual(viewModel.cities.count, 2)
        XCTAssertTrue(viewModel.cities.contains(where: { $0.name == "Mendoza" }))
        XCTAssertTrue(viewModel.cities.contains(where: { $0.name == "Mar del Plata" }))
    }

    func testFetchDataSearchBFilter() {
        // Arrange: insert test data
        _ = makeCity(name: "Buenos Aires", id: 1)
        _ = makeCity(name: "Mendoza", id: 2)
        _ = makeCity(name: "Mar del Plata", id: 3)

        try? context.save()

        // Act: buscar "B" debería traer Mendoza y Mar del Plata
        viewModel.searchText = "B"
        viewModel.fetchData(reset: true)

        // Assert
        XCTAssertEqual(viewModel.cities.count, 1)
        XCTAssertTrue(viewModel.cities.contains(where: { $0.name == "Buenos Aires" }))
    }

    func testFetchDataFavoritesOnly() {
        // Arrange: insert test data
        _ = makeCity(name: "Buenos Aires", id: 1)
        _ = makeCity(name: "Mendoza", id: 2, isFavorite: true)
        _ = makeCity(name: "Mar del Plata", id: 3)

        try? context.save()

        // Act: filtrar favoritos
        viewModel.showFavoritesOnly = true
        viewModel.fetchData(reset: true)

        // Assert
        XCTAssertEqual(viewModel.cities.count, 1)
        XCTAssertEqual(viewModel.cities.first?.name, "Mendoza")
    }

    func testFetchDataSearchAndFavoritesCombinedSearchinbM() {
        // Arrange
        _ = makeCity(name: "Buenos Aires", id: 1)
        _ = makeCity(name: "Mendoza", id: 2, isFavorite: true)
        _ = makeCity(name: "Mar del Plata", id: 3)

        try? context.save()

        // Act: buscar 'M' y favoritos
        viewModel.searchText = "M"
        viewModel.showFavoritesOnly = true
        viewModel.fetchData(reset: true)

        // Assert
        XCTAssertEqual(viewModel.cities.count, 1)
        XCTAssertEqual(viewModel.cities.first?.name, "Mendoza")
    }

    func testFetchDataSearchAndFavoritesCombinedSearchinB() {
        // Arrange
        _ = makeCity(name: "Buenos Aires", id: 1)
        _ = makeCity(name: "Mendoza", id: 2, isFavorite: true)
        _ = makeCity(name: "Mar del Plata", id: 3)

        try? context.save()

        // Act: buscar 'M' y favoritos
        viewModel.searchText = "B"
        viewModel.showFavoritesOnly = true
        viewModel.fetchData(reset: true)

        // Assert
        XCTAssertEqual(viewModel.cities.count, 0)
    }
}

extension CitiesListViewModelTests {
    func makeCity(name: String, id: Int, isFavorite: Bool = false) -> CityItem {
        let city = CityItem(
            country: "AR",
            name: name,
            id: id,
            lat: -34.6,
            lon: -58.4
        )
        city.isFavorite = isFavorite
        context.insert(city)
        return city
    }
}
