//
//  File.swift
//  
//
//  Created by Dave Duprey on 17/08/2021.
//

#if !os(watchOS)

import Foundation
import MapKit


public protocol W3WMapKitCompatibility {
  var mapType: MKMapType { get set }
  
  var overlays: [MKOverlay] { get }
  func removeOverlay(_ overlay: MKOverlay)
  func addOverlay(_ overlay: MKOverlay)
  
  var annotations: [MKAnnotation] { get }
  func addAnnotation(_ annotation: MKAnnotation)
  func removeAnnotation(_ annotation: MKAnnotation)

  var region:  MKCoordinateRegion { get }
  func setRegion(_ region: MKCoordinateRegion, animated: Bool)
  func setCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool)
}


#endif
