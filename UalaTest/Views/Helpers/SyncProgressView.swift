//
//  SyncProgressView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 21/05/2025.
//

import SwiftUI

struct SyncProgressView: View {
    let progress: Double
    let isImporting: Bool

    var body: some View {
        ZStack {
            Text("Sincronizando... \(Int(progress * 100))%")
            ProgressView(value: progress)
                .padding(.horizontal, 48)
                .padding(.top, 32)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(.thinMaterial)
        .isHidden(!isImporting)
    }
}
