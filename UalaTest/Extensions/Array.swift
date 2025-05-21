//
//  Array.swift
//  UalaTest
//
//  Created by Luciano Putignano on 21/05/2025.
//

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
