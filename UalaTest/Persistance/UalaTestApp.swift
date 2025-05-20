//
//  UalaTestApp.swift
//  UalaTest
//
//  Created by Luciano Putignano on 15/05/2025.
//

import SwiftUI

@main
struct UalaTestApp: App {
    var body: some Scene {
        WindowGroup {
            CitiesListView(viewModel: CitiesListViewModel())
        }
        .modelContainer(for: CityItem.self)
    }
}
