//
//  File.swift
//  
//
//  Created by Dave Duprey on 04/11/2021.
//

import Foundation
import CoreLocation


/// given coordinates, find the center and span containing all of them
class W3WAreaMath {

  var middle = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
  var count  = 0
  var minLat = Double.infinity
  var minLng = Double.infinity
  var maxLat = -Double.infinity
  var maxLng = -Double.infinity

  
  /// add a coordinate to the list
  func add(coordinates: CLLocationCoordinate2D) {
    if minLat > coordinates.latitude  {
      minLat = coordinates.latitude
    }
    if minLng > coordinates.longitude {
      minLng = coordinates.longitude
    }
    if maxLat < coordinates.latitude  {
      maxLat = coordinates.latitude
    }
    if maxLng < coordinates.longitude {
      maxLng = coordinates.longitude
    }
    
    count += 1
  }

  
  /// return the center of the group of all the coordinates
  func getCenter() -> CLLocationCoordinate2D {
    if count > 0 {
      middle.latitude  = (maxLat - minLat) / 2.0 + minLat
      middle.longitude = (maxLng - minLng) / 2.0 + minLng
    }

    return middle
  }


  /// return the span from the center of the group in lat,lng 
  func getSpan() -> (Double, Double) {
    let latSpan  = min(max(-90.0,  (maxLat - minLat) * 1.5), 90.0)
    let longSpan = min(max(-180.0, (maxLng - minLng) * 1.5), 180.0)

    return (latSpan, longSpan)
  }
  
}
