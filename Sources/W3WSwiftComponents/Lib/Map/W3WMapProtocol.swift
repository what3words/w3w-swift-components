//
//  Created by Dave Duprey on 01/03/2022.
//

import Foundation
import MapKit
import W3WSwiftApi


/// A basic set of functions common to all W3W map objects
public protocol W3WMapProtocol {
  
  // set the language to use for three word addresses when they need to be looked up
  func set(language: String)
  
  // put a what3words annotation on the map showing the address
  func addMarker(at square: W3WSquare?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping (W3WSquare?, W3WMapError?) -> ())
  func addMarker(at suggestion: W3WSuggestion?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping (W3WSquare?, W3WMapError?) -> ())
  func addMarker(at words: String?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping (W3WSquare?, W3WMapError?) -> ())
  func addMarker(at coordinates: CLLocationCoordinate2D?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping (W3WSquare?, W3WMapError?) -> ())
  func addMarker(at squares: [W3WSquare]?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping ([W3WSquare]?, W3WMapError?) -> ())
  func addMarker(at suggestions: [W3WSuggestion]?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping ([W3WSquare]?, W3WMapError?) -> ())
  func addMarker(at words: [String]?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping ([W3WSquare]?, W3WMapError?) -> ())
  func addMarker(at coordinates: [CLLocationCoordinate2D]?, camera: W3WCenterAndZoom, color: UIColor?, completion: @escaping ([W3WSquare]?, W3WMapError?) -> ())
  
  // remove what3words annotations from the map if they are present
  func removeMarker(at suggestion: W3WSuggestion?)
  func removeMarker(at words: String?)
  func removeMarker(at squares: [W3WSquare]?)
  func removeMarker(at suggestions: [W3WSuggestion]?)
  func removeMarker(at words: [String]?)
  func removeMarker(at square: W3WSquare?)
  
  // COMING SOON: show the "selected" outline around a square
  //func select(at: W3WSquare)

  // COMING SOON: remove the selection from the selected square
  //func unselect()
  
  // COMING SOON: show the "hover" outline around a square
  //func hover(at: CLLocationCoordinate2D)
  
  // COMING SOON: hide the "hover" outline around a square
  //func unhover()
  
  // get the list of added squares
  func getAllMarkers() -> [W3WSquare]
  
  // remove what3words annotations from the map if they are present
  func removeAllMarkers()
  
  // COMING SOON: find a marker by it's coordinates and return it if it exists in the map
  //func findMarker(by coordinates: CLLocationCoordinate2D) -> W3WSquare?
  
  // sets the size of a square after .zoom is used in a show() call
  func set(zoomInPointsPerSquare: CGFloat)
  
  // returns the error enum for any error that occurs
  var onError: W3WMapErrorResponse { get set }
}


