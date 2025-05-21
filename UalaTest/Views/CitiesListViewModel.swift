//
//  CitiesListViewModel.swift
//  UalaTest
//
//  Created by Luciano Putignano on 20/05/2025.
//

import SwiftUI
import SwiftData

final class CitiesListViewModel: ObservableObject {
    private(set) var context: ModelContext!

    init() {}

    @MainActor
    func setContext(_ context: ModelContext) {
        self.context = context
        fetchData()
        loadTotalCount()
    }

    @Published var isLoading = false
    @Published var cities: [CityItem] = []
    @Published var searchText = ""
    @Published var showFavoritesOnly = false

    @Published var progress: Double = 0.0
    @Published var isImporting: Bool = false

    private var currentOffset: Int = 0
    private var totalCount: Int = 0
    private var fetchLimit: Int = 15

    var apiManager: APIManager = APIManager()

    var totalCities: Int {
        totalCount
    }

    private func loadTotalCount() {
        let descriptor = FetchDescriptor<CityItem>()
        totalCount = (try? context.fetchCount(descriptor)) ?? 0
    }

    @MainActor
    func loadMore() {
        guard !isLoading, cities.count < totalCount else { return }
        isLoading = true
        currentOffset += fetchLimit

        defer {
            isLoading = false
        }
        fetchData()
    }

    func fetchData(reset: Bool = false) {

        if reset {
            self.currentOffset = 0
            self.cities.removeAll()
        }

        var descriptor = FetchDescriptor<CityItem>(
            sortBy: [
                SortDescriptor(\.country, order: .forward),
                SortDescriptor(\.name, order: .forward)
            ]
        )

        descriptor.predicate = #Predicate { city in
            (searchText.isEmpty || city.name.starts(with: searchText)) &&
            (!showFavoritesOnly || city.isFavorite)
        }
        descriptor.fetchLimit = fetchLimit
        descriptor.fetchOffset = currentOffset

        if let result = try? context.fetch(descriptor) {
            DispatchQueue.main.async {
                self.cities += result
            }
        }
    }

    func toggleFavorite(for city: CityItem) {
        city.isFavorite.toggle()
        if self.context.hasChanges {
            do {
                try context?.save()
            } catch {
                
            }
        }
    }

    func fetchAndSaveCities() async throws {
        let container = try ModelContainer(for: CityItem.self)
        var context = self.context

        let cities = try await apiManager.fetchCities()

        print("Importando \(cities.count) ciudades...")

        let batchSize = 1000
        var counter = 0

        for city in cities {
            let cityEntity = CityItem(
                country: city.country,
                name: city.name,
                id: city.id,
                lat: city.coord.lat,
                lon: city.coord.lon
            )
            self.context.insert(cityEntity)

            counter += 1

            if counter % batchSize == 0 {
                let currentCounter = counter
                try self.context.save()
                context = ModelContext(container)
                print("Guardado batch \(counter / batchSize)")

                await MainActor.run {
                    self.progress = Double(currentCounter) / Double(totalCount)
                }
            }

        }

        if self.context.hasChanges {
            try context?.save()
        }

        loadTotalCount()
        fetchData(reset: true)

        await MainActor.run {
            self.progress = 1.0
            self.isImporting = false
        }
    }
}

