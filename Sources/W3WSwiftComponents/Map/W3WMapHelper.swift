//
//  File.swift
//  
//
//  Created by Dave Duprey on 06/09/2021.
//
#if !os(macOS) && !os(watchOS)

import Foundation
import MapKit
import W3WSwiftApi


public class W3WMapHelper: NSObject, W3WMapViewProtocol, MKMapViewDelegate {
  public var w3wMapData: W3WMapData?
  public var w3wMapView: MKMapView

  /// returns the error enum for any error that occurs
  public var onError: W3WMapErrorResponse = { _ in }
  
  /// called when an annotation is tapped
  public var onMarkerSelected: (W3WSquare) -> () = { _ in }

  
  public var overlays: [MKOverlay] {
    get {
      return w3wMapView.overlays
    }
  }
  
  public var annotations: [MKAnnotation] {
    return w3wMapView.annotations
  }
  
  public var region:  MKCoordinateRegion {
    return w3wMapView.region
  }
  
  public var mapType: MKMapType {
    get {
      return w3wMapView.mapType
    }
    set {
      w3wMapView.mapType = newValue
      self.redrawAll() // redraw lines and stuff after the map type changes
    }
  }
  
  
  // MARK: W3WMapViewProtocol

  public init(_ w3w: W3WProtocolV3, map: MKMapView, language: String = W3WSettings.defaultLanguage) {
    self.w3wMapView = map
    self.w3wMapData = W3WMapData(w3w, language: language)
  }
  
  
  public func removeOverlay(_ overlay: MKOverlay) {
    w3wMapView.removeOverlay(overlay)
  }

  public func addOverlay(_ overlay: MKOverlay) {
    w3wMapView.addOverlay(overlay)
  }

  public func addAnnotation(_ annotation: MKAnnotation) {
    w3wMapView.addAnnotation(annotation)
  }

  public func removeAnnotation(_ annotation: MKAnnotation) {
    w3wMapView.removeAnnotation(annotation)
  }

  public func setRegion(_ region: MKCoordinateRegion, animated: Bool) {
    w3wMapView.setRegion(region, animated: animated)
  }

  public func setCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
    w3wMapView.setCenter(coordinate, animated: animated)
  }

  
  
  // MARK: UIMapViewDelegates

  
  /// hijack this delegate call and update the grid, then pass control to the external delegate
  @available(iOS 11, *)
  public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    updateMap()
  }

  /// hijack this delegate call and update the grid, then pass control to the external delegate
  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    updateMap()
    //w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
  }
  
  
  /// hijack this delegate call and update the grid, then pass control to the external delegate
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    updateMap()
    //w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
  }


  /// ALLOW GRID TO BE DRAWN
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let w3wOverlay = mapRenderer(overlay: overlay) {
      return w3wOverlay
    }
    return MKOverlayRenderer()
  }


  /// ALLOW W3W PINS TO BE DRAWN
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let a = getMapAnnotationView(annotation: annotation) {
      return a
    }

    return nil
  }

  
  public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let markerView = view.annotation as? W3WAnnotation {
      if let square = markerView.square {
        onMarkerSelected(square)
      }
    }
  }

}


#endif
