//
//  CityRowView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 21/05/2025.
//

import SwiftUI

struct CityRowView: View {
    let city: CityItem
    let toggleFavorite: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(city.name) - \(city.country)").font(.headline)
                Text("lat: \(city.lat), lon: \(city.lon)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                toggleFavorite()
            } label: {
                Image(systemName: city.isFavorite ? "star.fill" : "star")
                    .foregroundColor(city.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
    }
}
