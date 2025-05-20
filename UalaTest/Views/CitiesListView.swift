//
//  CitiesListView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 15/05/2025.
//

import SwiftUI
import SwiftData

struct CitiesListView: View {

    @ObservedObject var viewModel: CitiesListViewModel
    @Environment(\.modelContext) private var context

    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var cities: [CityItem] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cities.indices, id: \.self) { index in
                    let city = viewModel.cities[index]

                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(city.name) - \(city.country)").font(.headline)
                            Text("Coord: lat: \(city.lat), long: \(city.lon)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button {
                            city.isFavorite.toggle()
                            Task {
                                viewModel.fetchData()
                            }
                        } label: {
                            Image(systemName: city.isFavorite ? "star.fill" : "star")
                                .foregroundColor(city.isFavorite ? .yellow : .gray)
                        }
                        .buttonStyle(.borderless)
                    }
                    .onAppear {
                        if index == viewModel.cities.count - 1 && viewModel.cities.count < viewModel.totalCities {
                            viewModel.loadMore()
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .isHidden(viewModel.isLoading)
            .searchable(text: $viewModel.searchText, prompt: "Buscar ciudad")
            .onChange(of: viewModel.searchText) {
                viewModel.fetchData(reset: true)
            }
            .onChange(of: viewModel.showFavoritesOnly) {
                viewModel.fetchData(reset: true)
            }
            .navigationTitle("Ciudades")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Descargar") {
                        Task {
                            do {
                                try await viewModel.fetchAndSaveCities()
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $viewModel.showFavoritesOnly) {
                        Image(systemName: viewModel.showFavoritesOnly ? "star.fill" : "star")
                    }
                    .toggleStyle(.button)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Borrar Todo") {
                        viewModel.deleteAllCities()
                    }
                }
            }
            .onAppear {
                viewModel.setContext(context)
            }
        }

    }
}
