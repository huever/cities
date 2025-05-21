//
//  EmptyBannerView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 21/05/2025.
//

import SwiftUI

struct EmptyBannerView: View {
    let emptyCities: Bool
    let emptyResults: Bool

    var body: some View {
        VStack {
            Text("No hay resultados")
                .font(.title2)
                .foregroundColor(.primary)
            if (emptyCities) {
                Text("Sincronice antes de continuar")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(15)
        .isHidden(!emptyResults)
    }
}
