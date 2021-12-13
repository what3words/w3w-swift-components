//
//  MapViewController.swift
//  W3wComponents
//
//  Created by Dave Duprey on 31/05/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
#if !os(macOS) && !os(watchOS)


import UIKit
import MapKit
import W3WSwiftApi




// MARK:- W3MapView

//@available(iOS 13, *)
open class W3WMapView: MKMapView, W3WMapViewProtocol, MKMapViewDelegate {

  public var w3wMapData: W3WMapData?
  public var onError: W3WMapErrorResponse = { _ in }
  
  
  /// Convenience wrapper to get layer as its statically known type.
  public var w3wMapView: MKMapView {
    return self
  }

  
  /// make sure the grid and things are redrawn when the map type changes
  public override var mapType: MKMapType {
    didSet {
      redrawAll()
    }
  }
  
  
  public init() {
    super.init(frame: CGRect.zero)
    configure()
  }
  
  
  public init(_ w3w: W3WProtocolV3) {
    super.init(frame: CGRect.zero)
    configure(w3w: w3w)
  }
  
  
  public init(frame: CGRect, w3w: W3WProtocolV3) {
    super.init(frame: frame)
    configure(w3w: w3w)
  }

  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  

  func configure(w3w: W3WProtocolV3? = nil) {
    delegate = self
    
    if let w = w3w {
      w3wMapData = W3WMapData(w)
    } else {
      w3wMapData = W3WMapData(What3WordsV3(apiKey: ""))
    }
  }
  
  
  override public var delegate: MKMapViewDelegate? {
    didSet {
      if !(delegate is W3WMapView) {
        w3wMapData?.externalDelegate = delegate
        delegate = self
      }
    }
  }
  
  
  public func set(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
    w3wMapData?.w3w = w3w
    w3wMapData?.language = language
  }
  
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    //print("XXX")
  }
  
  
  // MARK: MKMapViewDelegate
  
  
  /// if this is calling for a grid lines renderer, send that, otherwise if the `externalDelegate` is set, call it and return something, otherwise, just send back a generic renderer
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    if let w3wOverlay = mapRenderer(overlay: overlay) {
      return w3wOverlay
    }
    
    return w3wMapData?.externalDelegate?.mapView?(mapView, rendererFor: overlay) ?? MKOverlayRenderer()

  }
  
  /// hijack this delegate call and update the grid, then pass control to the external delegate
  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    updateMap()
    w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
  }
  
  /// hijack this delegate call and update the grid, then pass control to the external delegate
  @available(iOS 11, *)
  public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    updateMap()
    w3wMapData?.externalDelegate?.mapViewDidChangeVisibleRegion?(mapView)
  }
  
  /// hijack this delegate call and update the grid, then pass control to the external delegate
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    updateMap()
    w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
  }
  
  /// delegate callback to provide a cusomt annotation view
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let a = getMapAnnotationView(annotation: annotation) {
      return a
    }

    return w3wMapData?.externalDelegate?.mapView?(mapView, viewFor: annotation)
  }

  
  // MARK: MKMapViewDelegate passthrough

  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
    w3wMapData?.externalDelegate?.mapViewWillStartLoadingMap?(mapView)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    w3wMapData?.externalDelegate?.mapViewDidFinishLoadingMap?(mapView)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
    w3wMapData?.externalDelegate?.mapViewDidFailLoadingMap?(mapView, withError: error)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
    w3wMapData?.externalDelegate?.mapViewWillStartRenderingMap?(mapView)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
    w3wMapData?.externalDelegate?.mapViewDidFinishRenderingMap?(mapView, fullyRendered: fullyRendered)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
    w3wMapData?.externalDelegate?.mapViewWillStartLocatingUser?(mapView)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
    w3wMapData?.externalDelegate?.mapViewDidStopLocatingUser?(mapView)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didUpdate: userLocation)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didFailToLocateUserWithError: error)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didChange: mode, animated: animated)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didAdd: views)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    w3wMapData?.externalDelegate?.mapView?(mapView, annotationView: view, calloutAccessoryControlTapped: control)
  }
  
  /// pass delegate call on the the external delegate if there is one
  @available(iOS 11, *)
  public func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
    return w3wMapData?.externalDelegate?.mapView?(mapView, clusterAnnotationForMemberAnnotations: memberAnnotations) ?? MKClusterAnnotation(memberAnnotations: memberAnnotations)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
    w3wMapData?.externalDelegate?.mapView?(mapView, annotationView: view, didChange: newState, fromOldState: oldState)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didSelect: view)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didDeselect: view)
  }
  
  /// pass delegate call on the the external delegate if there is one
  public func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
    w3wMapData?.externalDelegate?.mapView?(mapView, didAdd: renderers)
  }
  
}



#endif
