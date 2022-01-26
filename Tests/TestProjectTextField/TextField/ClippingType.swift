//
//  clippingType.swift
//  TextField
//
//  Created by Tim Smith on 05/11/2021.
//

import Foundation
enum ClippingType : String, CaseIterable {
    case Rectangle = "Rectangle"
    case Polygon = "Polygon"
    case Circle = "Circle"
    case All = "All"
    case CountryGB = "CountryGB"
    case CountryAR = "CountryAR"
    case CountryRU = "CountryRU"
    case invalidCountry = "invalidCountry"
    case NoClipping = "NoClipping"
    case PreferLandOff = "PreferLandOff"
    case InvalidCountryCode = "InvalidCountryCode"
    case FiveResults = "FiveResults"
}
