//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/08/2021.
//

import Foundation
import MapKit
import W3WSwiftApi


//@available(iOS 13, *)
public struct W3WMapData {
  
  /// MapKit class that hold the graphical lines
  @available(iOS 13, *)
  lazy var gridLines: W3WMapGridLines? = nil
  
  /// renderer for grid lines
  @available(iOS 13, *)
  lazy var gridRenderer: W3WMapGridRenderer? = nil
  
  /// allows other things like button s to be placed on the map
  var subViews = W3WSubviewManager()
  
  /// highighted individual squares on the map
  var squares = [W3WSquare]()
  
  /// renderer for squares
  //var squaresRenderer: W3WMapSquaresRenderer? = nil
  
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
  

//  func convertToSquaresWithCoordinates(suggestions: [W3WSuggestion]) -> [W3WSquare] {
//    var squares = [W3WSquare]()
//    
//    for suggestion in suggestions {
//      squares.append(W3WApiSquare(words: suggestion.words))
//    }
//    
//    return ensureSquaresHaveCoordinates(squares: squares)
//  }
//  
//  
//  func convertToSquaresWithCoordinates(words: [String]) -> [W3WSquare] {
//    var squares = [W3WSquare]()
//    
//    for word in words {
//      squares.append(W3WApiSquare(words: word))
//    }
//    
//    return ensureSquaresHaveCoordinates(squares: squares)
//  }
//  
//  
//  func convertToSquares(coordinates: [CLLocationCoordinate2D]) -> [W3WSquare] {
//    var squares = [W3WSquare]()
//    
//    for coordinate in coordinates {
//      squares.append(W3WApiSquare(coordinates: coordinate))
//    }
//    
//    return ensureSquaresHaveCoordinates(squares: squares)
//  }
//  
//  
//  func ensureSquareHasCoordinates(square: W3WSquare) -> W3WSquare? {
//    let s = ensureSquaresHaveCoordinates(squares: [square])
//    return s.first
//  }
//  
//  
//  func ensureSquaresHaveCoordinates(squares: [W3WSquare]) -> [W3WSquare] {
//    if W3WThread.isMain() {
//      print(#function, " must NOT be called on main thread")
//      abort()
//    }
//    
//    var goodSquares = [W3WSquare]()
//    
//    let tasks = DispatchGroup()
//    
//    for square in squares {
//      if square.coordinates == nil {
//        if let words = square.words {
//          tasks.enter()
//          self.w3w?.convertToCoordinates(words: words) { result, error in
//            if let s = result {
//              goodSquares.append(s)
//            }
//            tasks.leave()
//          }
//        }
//      } else if square.words == nil {
//        if let coordinates = square.coordinates {
//          tasks.enter()
//          self.w3w?.convertTo3wa(coordinates: coordinates, language: language) { result, error in
//            if let s = result {
//              goodSquares.append(s)
//            }
//            tasks.leave()
//          }
//        }
//      } else {
//        goodSquares.append(square)
//      }
//    }
//    
//    tasks.wait()
//    
//    return goodSquares
//  }

  
}
