//
//  Utils.swift
//  UalaTest
//
//  Created by Luciano Putignano on 21/05/2025.
//
import SwiftUI

class Utils {
    static func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
