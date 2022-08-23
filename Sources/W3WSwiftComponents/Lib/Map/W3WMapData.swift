//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/08/2021.
//
#if !os(macOS) && !os(watchOS)

import Foundation
import MapKit
import W3WSwiftApi


public struct W3WMapData {
  
  /// MapKit class that holds the graphical lines
  /// This ridiculous construct is a workaround for an issue
  /// Xcode 14 brought around using @available with stored
  /// properties.  So, we use a computed property instead
  @available(iOS 13, *)
  var gridLines: W3WMapGridLines? {
    get { return gridLinePointer as? W3WMapGridLines }
    set { gridLinePointer = newValue }
  }
  var gridLinePointer: Any? = nil
  
  /// renderer for grid lines
  /// This ridiculous construct is a workaround for an issue
  /// Xcode 14 brought around using @available with stored
  /// properties.  So, we use a computed property instead
  @available(iOS 13, *)
  var gridRenderer: W3WMapGridRenderer? {
    get { return gridRendererPointer as? W3WMapGridRenderer }
    set { gridRendererPointer = newValue }
  }
  var gridRendererPointer: Any? = nil

  /// highighted individual squares on the map
  var squares = [W3WSquare]()
  
  /// the service to get the grid line data from
  var w3w: W3WProtocolV3?
  
  /// language to use currently
  var language = W3WSettings.defaultLanguage
  
  /// make sure calls to gridUpdate() don't happen too quickly
  var gridUpdateDebouncer: W3WDebouncer!
  
  /// keep track of the zoom level so we can change pins to squares at a certain point
  var lastZoomPointsPerSquare = CGFloat(0.0)

  /// we hijack the delegate, so we remember the user's one, if any, and use it to pass through calls
  var externalDelegate: MKMapViewDelegate?
  
  /// set's how many meters are visible when show(:camera: .zoom) is called
  var visibleZoomPointsPerSquare = W3WSettings.mapDefaultZoomPointsPerSquare  
  
  
  public init(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
    self.w3w = w3w
    self.set(language: language)
    
    // make sure calls to gridUpdate() don't happen too quickly
    gridUpdateDebouncer = W3WDebouncer(delay: 0.3, handler: { })
  }
  
  
  public mutating func set(language: String) {
    self.language = language
  }
  
  
}


#endif
