//
//  File.swift
//  
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
  func show(_ square: W3WSquare?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ suggestion: W3WSuggestion?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ words: String?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ coordinates: CLLocationCoordinate2D?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ squares: [W3WSquare]?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ suggestions: [W3WSuggestion]?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ words: [String]?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  func show(_ coordinates: [CLLocationCoordinate2D]?, camera: W3WCenterAndZoom, color: UIColor?, style: W3WMarkerStyle)
  
  // remove what3words annotations from the map if they are present
  func hide(_ suggestion: W3WSuggestion?)
  func hide(_ words: String?)
  func hide(_ squares: [W3WSquare]?)
  func hide(_ suggestions: [W3WSuggestion]?)
  func hide(_ words: [String]?)
  func hide(_ square: W3WSquare?)
  
  // remove what3words annotations from the map if they are present
  func hideAll()
  
  // sets the size of a square after .zoom is used in a show() call
  func set(zoomInPointsPerSquare: CGFloat)
  
  // returns the error enum for any error that occurs
  var onError: W3WMapErrorResponse { get set }
}


