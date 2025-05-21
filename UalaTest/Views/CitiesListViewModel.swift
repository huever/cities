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
    private var totalProcessed = 0

    private var currentOffset: Int = 0
    private var totalCount: Int = 0
    private var fetchLimit: Int = 15

    var apiManager: APIManager = APIManager()

    var totalCities: Int {
        totalCount
    }

    private func loadTotalCount() {
        do {
            totalCount = try context.fetchCount(FetchDescriptor<CityItem>())
        } catch {
            print("Error contando ciudades: \(error)")
            totalCount = 0
        }
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

    @MainActor
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

        do {
            let result = try context.fetch(descriptor)
            self.cities += result
        } catch {
            print("Error al buscar ciudades: \(error)")
        }
    }

    func toggleFavorite(for city: CityItem) {
        city.isFavorite.toggle()
        do {
            try context.save()
        } catch {
            print("Error al guardar favorito: \(error)")
        }
    }

    @MainActor
    func updateProgress(processed: Int, total: Int) {
        totalProcessed += processed
        if total > 0 {
            let progress = Double(totalProcessed) / Double(total)
            self.progress = progress <= 1.0 ? progress : 1.0
        } else {
            self.progress = 0
        }
    }

    func fetchAndSaveCities() async throws {
        await MainActor.run {
            self.progress = 0
            self.isImporting = true
        }

        let container = try ModelContainer(for: CityItem.self)
        let cities = try await apiManager.fetchCities()

        guard !cities.isEmpty else {
            print("No se encontraron ciudades.")
            await MainActor.run {
                self.isImporting = false
                self.progress = 0.0
            }
            return
        }

        let batchSize = 50  // Puedes ajustar esto
        let chunks = cities.chunked(into: batchSize)

        let totalCities = cities.count

        try await withThrowingTaskGroup(of: Int.self) { group in
            for chunk in chunks {
                group.addTask {
                    let context = ModelContext(container)
                    var processed = 0

                    for city in chunk {
                        let fetchRequest = FetchDescriptor<CityItem>(
                            predicate: #Predicate { $0.id == city.id }
                        )

                        let existing = try context.fetch(fetchRequest)
                        if !existing.isEmpty {
                            continue
                        }

                        let cityEntity = CityItem(
                            country: city.country,
                            name: city.name,
                            id: city.id,
                            lat: city.coord.lat,
                            lon: city.coord.lon
                        )
                        context.insert(cityEntity)
                        processed += 1

                    }

                    if context.hasChanges {
                        try context.save()
                    }

                    await MainActor.run {
                        self.progress += Double(chunk.count) / Double(totalCities)
                    }

                    return processed
                }
            }
        }

        loadTotalCount()
        await fetchData(reset: true)

        await MainActor.run {
            self.totalProcessed = 0
            self.progress = 1.0
            self.isImporting = false
        }

        print("Importación terminada. \(totalProcessed) ciudades nuevas guardadas.")
    }
}
