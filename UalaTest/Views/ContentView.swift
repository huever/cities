//
//  ContentView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 15/05/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    //@ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var context
    
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var cities: [CityEntity] = []
    
    var filteredCitiesDescriptor: FetchDescriptor<CityEntity> {
        var descriptor = FetchDescriptor<CityEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        if showFavoritesOnly {
            descriptor.predicate = #Predicate { $0.isFavorite == true }
        }
        return descriptor
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cities) { city in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(city.name).font(.headline)
                            Text("País: \(city.country)")
                            Text("Coord: \(city.lat), \(city.lon)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            city.isFavorite.toggle()
                            fetchData()
                        } label: {
                            Image(systemName: city.isFavorite ? "star.fill" : "star")
                                .foregroundColor(city.isFavorite ? .yellow : .gray)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar ciudad")
            .onChange(of: searchText) { _ in fetchData() }
            .onChange(of: showFavoritesOnly) { _ in fetchData() }
            .onAppear(perform: fetchData)
            .navigationTitle("Ciudades")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Descargar") {
                        Task {
                            do {
                                let cities = try await APIManager.shared.fetchCities()
                                APIManager.shared.saveCities(cities, context: context)
                                fetchData()
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showFavoritesOnly) {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                    }
                    .toggleStyle(.button)
                }
            }
        }
    }
    
    private func fetchData() {
        var descriptor = FetchDescriptor<CityEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        descriptor.predicate = #Predicate { city in
            (searchText.isEmpty || city.name.starts(with: searchText)) &&
            (!showFavoritesOnly || city.isFavorite)
        }
        descriptor.fetchLimit = 100
        
        if let result = try? context.fetch(descriptor) {
            cities = result
        }
    }
}

extension ContentView {
    class ViewModel: ObservableObject {
        @Query var cities: [CityEntity]
        var apiManager: APIManager = APIManager()
        
        @MainActor
        func getCities(context: ModelContext) async {
            do {
                let cities = try await apiManager.fetchCities()
                apiManager.saveCities(cities, context: context)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
