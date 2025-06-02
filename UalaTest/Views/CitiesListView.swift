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
    @State private var path = NavigationPath()

    var body: some View {
        ZStack {
            NavigationSplitView(columnVisibility: .constant(.all)) {
                List {
                    ForEach(viewModel.cities.indices, id: \.self) { index in
                        let city = viewModel.cities[index]

                        NavigationLink(destination: MapView(city: City(from: city))) {
                            CityRowView(city: city, toggleFavorite: {
                                viewModel.toggleFavorite(for: city)
                            })
                            .onAppear {
                                if index == viewModel.cities.count - 1 && viewModel.cities.count < viewModel.totalCities {
                                    viewModel.loadMore()
                                }
                            }
                        }
                        .navigationTitle("Cities")
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("CellBackground"))
                            .padding(.all, 4)
                            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 2)
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSpacing(4)
                }

                .navigationDestination(for: CityItem.self) { city in
                    MapView(city: City(from: city))
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
                        Button("Sincronizar...") {
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
                        Button {
                            viewModel.showFavoritesOnly.toggle()
                            viewModel.fetchData(reset: true)
                        } label: {
                            Image(systemName: viewModel.showFavoritesOnly ? "star.fill" : "star")
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier("favorite-button")
                    }
                }
                .onAppear {
                    if viewModel.totalCities == 0 {
                        viewModel.setContext(context)
                    }
                }
            }
            detail: {
                MapView(city: City.defaultCity())
            }
            .navigationSplitViewStyle(.balanced)

            EmptyBannerView(
                emptyCities: viewModel.totalCities == 0,
                emptyResults: viewModel.cities.isEmpty
            )

            SyncProgressView(
                progress: viewModel.progress,
                isImporting: viewModel.isImporting
            )
        }
    }
}
