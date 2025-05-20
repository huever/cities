//
//  UIView.swift
//  UalaTest
//
//  Created by Luciano Putignano on 20/05/2025.
//
import SwiftUI

extension View {
    /// Hide or show the view based on a boolean value.
    /// Allows us not build the view when isHidden = true, so we get the free space back
    @ViewBuilder
    public func isHidden(_ hidden: Bool) -> some View {
        self.opacity(hidden ? 0 : 1)
            .frame(width: hidden ? 0 : nil, height: hidden ? 0 : nil)
    }
}
