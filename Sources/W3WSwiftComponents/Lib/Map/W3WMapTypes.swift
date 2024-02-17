//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/12/2020.
//
#if !os(macOS) && !os(watchOS)

import Foundation
import MapKit
import W3WSwiftCore


/// the map annotation for a three word square
public class W3WAnnotation: MKPointAnnotation {
  
  var square: W3WSquare?
  var style: W3WMarkerStyle = .circle
  var colour: UIColor?

  
  public init(square: W3WSquare, color: UIColor? = nil, style: W3WMarkerStyle = .circle) {
    super.init()
    
    self.colour = color
    self.style = style
    
    if let words = square.words {
      if W3WSettings.leftToRight {
        title = "///" + words
      } else {
        title = words + "///"
      }
    }
    
    if let coordinates = square.coordinates {
      coordinate = coordinates
    }
    
    self.square = square
  }
  
}


@available(iOS 13, *)
public class W3WMapGridLines: MKMultiPolyline {
}


@available(iOS 13, *)
public class W3WMapGridRenderer: MKMultiPolylineRenderer {
}


public class W3WMapSquareLines: MKPolyline {
}


public class W3WMapSquaresRenderer: MKPolylineRenderer {
}


public protocol W3WMapPins: AnyObject, W3WMapKitCompatibility {  // MKMapView {
  var w3wMapData:W3WMapData? { get set }
}


#endif


public enum W3WCenterAndZoom {
  case center
  case zoom
  case none
}



public enum W3WMarkerStyle {
  case pin
  case circle
}

