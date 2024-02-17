//
//  ClippingSettings.swift
//  TextField
//
//  Created by Tim Smith on 02/11/2021.
//

import Foundation
import W3WSwiftComponents
import CoreLocation
import W3WSwiftCore

class ClippingSettings
{

    func getRectangleClipping() -> W3WOption
    {
        let southWestPoint = CLLocationCoordinate2D(latitude: 49.180803, longitude: -8.001330)
        let northEastPoint = CLLocationCoordinate2D(latitude: 58.470001, longitude: 2.158991)
        return W3WOption.clipToBox(southWest: southWestPoint, northEast: northEastPoint)
    }
    
    func getPolyClipping() -> W3WOption
    {
        var wstowPolyCoords : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        func addPoint(_ lat : Double, _ long : Double) -> CLLocationCoordinate2D
        {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
             wstowPolyCoords.append(addPoint(51.598583, -0.040604))
             wstowPolyCoords.append(addPoint(51.600691, -0.016703))
             wstowPolyCoords.append(addPoint(51.600143, -0.007478))
             wstowPolyCoords.append(addPoint(51.581851, 0.000835))
             wstowPolyCoords.append(addPoint(51.581851, 0.000836))
             wstowPolyCoords.append(addPoint(51.581851, 0.000837))
             wstowPolyCoords.append(addPoint(51.581851, 0.000838))
             wstowPolyCoords.append(addPoint(51.581851, 0.000839))
             wstowPolyCoords.append(addPoint(51.575373, -0.012646))
             wstowPolyCoords.append(addPoint(51.570550, -0.025094))
             wstowPolyCoords.append(addPoint(51.587274, -0.040544))
             wstowPolyCoords.append(addPoint(51.598583, -0.040691))
             wstowPolyCoords.append(addPoint(51.598583, -0.040592))
             wstowPolyCoords.append(addPoint(51.598583, -0.040593))
             wstowPolyCoords.append(addPoint(51.598583, -0.040594))
             wstowPolyCoords.append(addPoint(51.598583, -0.040595))
             wstowPolyCoords.append(addPoint(51.598583, -0.040596))
             wstowPolyCoords.append(addPoint(51.598583, -0.040597))
             wstowPolyCoords.append(addPoint(51.598583, -0.040598))
             wstowPolyCoords.append(addPoint(51.598583, -0.040599))
             wstowPolyCoords.append(addPoint(51.598583, -0.040600))
             wstowPolyCoords.append(addPoint(51.598583, -0.040601))
             wstowPolyCoords.append(addPoint(51.598583, -0.040602))
             wstowPolyCoords.append(addPoint(51.598583, -0.040603))
             wstowPolyCoords.append(addPoint(51.598583, -0.040604))
        return W3WOption.clipToPolygon(wstowPolyCoords)
    }
    
    func getCountryOption(_ coutryCode : String) -> W3WOption
    {
        return W3WOption.clipToCountry(W3WBaseCountry(code: coutryCode))
    }

    func getCircleClipping()  -> W3WOption
    {
        return W3WOption.clipToCircle(center: CLLocationCoordinate2D(latitude: 55.136930, longitude: -4.288321), radius: 680.0)
    }
    
    func getFocus() -> W3WOption
    {
        return W3WOption.focus(CLLocationCoordinate2D(latitude: 50.0, longitude: 0.1))
    }
    
    func preferLandOff() -> W3WOption
    {
        return W3WOption.preferLand(false)
    }
        
    func All() -> [W3WOption]
    {
        return [getFocus()]
    }
    
//    func addPoint(_ lat : Double, _ long : Double) -> CLLocationCoordinate2D
//    {
//        return CLLocationCoordinate2D(latitude: lat, longitude: long)
//    }
    
    func setAutosuggestResultsToFive()-> W3WOption
    {
        return W3WOption.numberOfResults(5)
    }
    
    func getClippingOptions(option : ClippingType) -> [W3WOption]
    {
        print("clippingSetings - getClippingOptions")
        switch option
        {
            case .Circle:
                return [getCircleClipping(), getFocus()]
            case .Rectangle:
                return [getRectangleClipping(), getFocus()]
            case .NoClipping:
                return [getFocus()]
            case .All:
                return [getCountryOption("GB"), getCircleClipping(), getRectangleClipping(),  getFocus() ]
            case .Polygon:
                return [getPolyClipping(), getFocus()]
            case .CountryGB:
                return [getCountryOption("GB"), getFocus()]
            case .CountryAR:
                return [getCountryOption("AR"), getFocus()]
            case .CountryRU:
                return [getCountryOption("RU"), getFocus()]
            case .PreferLandOff:
                return [preferLandOff(), getFocus()]
        case .InvalidCountryCode:
            return [getCountryOption("GBR"), getFocus()]
        case .FiveResults:
            return [setAutosuggestResultsToFive(), getFocus()]
            default :
                return [getFocus()]
        }
    }
}
