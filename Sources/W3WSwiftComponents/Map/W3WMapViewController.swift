//
//  MapViewController.swift
//  W3wComponents
//
//  Created by Dave Duprey on 31/05/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import MapKit
import W3WSwiftApi


#if !os(watchOS)


// MARK:- W3WMapViewController


open class W3WMapViewController: UIViewController, UIGestureRecognizerDelegate, W3WMapViewProtocol {
  

  /// called when the user taps a square in the map
  public var onSquareSelected: (W3WSquare) -> () = { _ in }
  
  /// called when the user taps a square in the map
  public var onMarkerSelected: (W3WSquare) -> () = { _ in }
  
  /// returns the error enum for any error that occurs
  public var onError: W3WMapErrorResponse = { _ in }

  
  // MARK:- Init
  
  
  public convenience init(_ w3w: W3WProtocolV3) {
    self.init()
    set(w3w)
  }
  
  
  /// initializer override to instantiate the W3WOcrScannerView
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  
  /// initializer override to instantiate the `W3WOcrScannerView`
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  
  /// This must be called to allow the map to make what3words calls
  public func set(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
    mapHelper = W3WMapHelper(w3w, map: w3wMapView)
    
    // let map helper take care of the delegate callbacks
    w3wMapView.delegate = mapHelper
    
    // if a marker was tapped
    mapHelper?.onMarkerTapped = { square in
      self.onMarkerSelected(square)
    }
    
    // forward any map helper errors to the owner of this object
    mapHelper?.onError = { error in
      self.onError(error)
    }
  }

  
  // MARK: W3WMapKitCompatibility
  
  
  public var w3wMapData: W3WMapData? {
    get {
      return mapHelper?.w3wMapData
    }
    set {
      mapHelper?.w3wMapData = newValue
    }
  }
  
  public var mapType: MKMapType {
    get {
      return mapHelper?.mapType ?? .standard
    }
    set {
      mapHelper?.mapType = newValue
      self.redrawAll() // redraw lines and stuff after the map type changes
    }
  }
  
  public var overlays: [MKOverlay] {
    get {
      return mapHelper?.overlays ?? []
    }
  }
  
  public func removeOverlay(_ overlay: MKOverlay) {
    mapHelper?.removeOverlay(overlay)
  }
  
  public func addOverlay(_ overlay: MKOverlay) {
    mapHelper?.addOverlay(overlay)
  }
  
  public func addAnnotation(_ annotation: MKAnnotation) {
    mapHelper?.addAnnotation(annotation)
  }

  public func removeAnnotation(_ annotation: MKAnnotation) {
    mapHelper?.removeAnnotation(annotation)
  }
  

  public var annotations: [MKAnnotation] {
    get {
      return w3wMapView.annotations
    }
  }
  
  public var region: MKCoordinateRegion = MKCoordinateRegion()
  
  
  public func setRegion(_ region: MKCoordinateRegion, animated: Bool) {
    mapHelper?.setRegion(region, animated: animated)
  }

  
  public func setCenter(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
    mapHelper?.setCenter(coordinate, animated: animated)
  }

  
  public var mapHelper: W3WMapHelper?
  
  
  
  // MARK: View Layer


  /// assign the `MKMapView` to `view` when the time comes
  public override func loadView() {
    view = MKMapView()
  }


  /// Convenience wrapper to get view as MKMapView
  public var w3wMapView: MKMapView {
    if !W3WThread.isMain() {
      print("mapView must only be accessed from the main thread: ", #function, #line)
    }
    return view as? MKMapView ?? MKMapView()
  }


  // MARK: Layout events
  
  
  
  func updateGeometry() {
    w3wMapData?.subViews.layout(in: w3wMapView)
  }
  
  
  func takeControlOfCompass() {
    self.w3wMapView.showsCompass = false
    
    //if #available(iOS 11, *) {
    //  let compass = MKCompassButton(mapView: self.w3wMapView)
    //  compass.compassVisibility = .visible
    //  attach(view: compass, position: .topRight)
    //}
  }

  
  // MARK: Touch Events


  /// add the gesture recognizer for tap
  func attachTapRecognizer() {
    /// detect user taps
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1

    // A kind of tricky thing to make sure double tap doesn't trigger single tap
    let doubleTap = UITapGestureRecognizer(target: self, action:nil)
    doubleTap.numberOfTapsRequired = 2
    w3wMapView.addGestureRecognizer(doubleTap)
    tap.require(toFail: doubleTap)

    // don't let the tap trickle through to the parent view
    //tap.cancelsTouchesInView = true
    
    tap.delegate = self

    w3wMapView.addGestureRecognizer(tap)
  }


  /// decide whether or not allow the touch event through.  denied if it is on a subview 
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    print(type(of: touch.view))
    if isNotPArtOfTheMap(view: touch.view) {
      return false
    } else {
      return true
    }
  }
  
  
  func isNotPArtOfTheMap(view: UIView?) -> Bool {
    if view == nil {
      return false
    } else if view is UITableView || view is UITextField || view is MKAnnotationView {
      return true
    } else {
      return isNotPArtOfTheMap(view: view?.superview)
    }
  }
  
  
  /// when the user taps the map this is called and it gets the square info and sends it using the closure
  @objc func tapped(_ gestureRecognizer : UITapGestureRecognizer) {
    checkConfiguration()
        
//    if let _ = self.findPin(s) {
//      self.onMarkerSelected(s)
//    } else if let _ = self.findSquare(s) {
//      self.onMarkerSelected(s)
//    }

    let location = gestureRecognizer.location(in: w3wMapView)
    let coordinates = w3wMapView.convert(location, toCoordinateFrom: w3wMapView)
    mapHelper?.w3wMapData?.w3w?.convertTo3wa(coordinates: coordinates, language: mapHelper?.w3wMapData?.language ?? W3WSettings.defaultLanguage) { square, error in
      if let e = error {
        W3WThread.runOnMain {
          self.onError(W3WMapError.apiError(error: e))
        }
      }
      if let s = square {
        W3WThread.runOnMain {
          self.onSquareSelected(s)
        }
      }
    }
  }



  // MARK: UIViewController Events

  
  open override func viewDidLoad() {
    super.viewDidLoad()

    attachTapRecognizer()
    DispatchQueue.main.async {
      self.takeControlOfCompass()
    }
  }

  
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateGeometry()
  }


  // MARK: Subviews

  
  public func attach(textField: W3WAutoSuggestTextField) {
    w3wMapView.addSubview(textField)
    w3wMapData?.subViews.add(view: textField, position: .topCenter)
    w3wMapData?.subViews.layout(in: w3wMapView)
  }
  
  
  public func attach(view: UIView, position: W3WViewPlacement) {
    w3wMapView.addSubview(view)
    w3wMapData?.subViews.add(view: view, position: position)
    w3wMapData?.subViews.layout(in: w3wMapView)
    
    // if a map type button was added, then wire up an action to it
    if let mapButton = view as? W3WMapTypeButton {
      mapButton.tapped = { mapType in
        self.mapHelper?.mapType = mapType
      }
    }
  }

  
  public func attach(searchController: W3WAutoSuggestSearchController) {
    if #available(iOS 11, *) {
      navigationItem.searchController = searchController
      //self.navigationItem.titleView = searchController.searchBar
      searchController.isActive = true
      navigationItem.hidesSearchBarWhenScrolling = true

    } else {
      searchController.searchBar.sizeToFit()
      w3wMapView.addSubview(searchController.searchBar)
    }
  }
  

}











/// view controller displaying a map overlayed with a what3words grid, and functrions to add markers
//open class W3WMapViewController: UIViewController, UIGestureRecognizerDelegate { //}, W3WMapViewControllerProtocol, MKMapViewDelegate  {
//
//  /// closure called when user selects a square on the map
//  public var onSquareSelected: (W3WSquare) -> () = { _ in }
//
//  /// closure called when user selects a square on the map
//  public var onAnnotationSelected: (W3WSquare) -> () = { _ in }
//
//  public var mapManager: W3WMapManager?
//
//  /// data for the map
//  //public var w3wMapData: W3WMapData?
//
//  /// place to hold a text field if added
////  var textField: W3WAutoSuggestTextField?
//
//  /// other views
//  //var subViews = W3WSubviewManager()
//
//
//  public convenience init(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
//    self.init()
//    set(w3w, language: language)
//  }
//
//
//  // MARK:- View Layer
//
//
//  /// assign the `W3WOcrScannerView` to `view` when the time comes
//  public override func loadView() {
//    view = MKMapView()
//  }
//
//
//  /// Convenience wrapper to get layer as its statically known type.
//  public var w3wMapView: MKMapView {
//    if !W3WThread.isMain() {
//      print("mapView must only be accessed from the main thread: ", #function, #line)
//    }
//    return view as? MKMapView ?? MKMapView()
//  }
//
//
//
//
//  // MARK:- View stuff
//
//
//  open override func viewDidLoad() {
//    super.viewDidLoad()
//
//    attachTapRecognizer()
//    //w3wMapView.delegate = self
//    w3wMapView.delegate = mapManager
//  }
//
//
//  public func attach(searchController: W3WAutoSuggestSearchController) {
//
//    if #available(iOS 11, *) {
//      navigationItem.searchController = searchController
//      //self.navigationItem.titleView = searchController.searchBar
//      searchController.isActive = true
//      navigationItem.hidesSearchBarWhenScrolling = true
//
//    } else {
//      searchController.searchBar.sizeToFit()
//      w3wMapView.addSubview(searchController.searchBar)
//    }
//  }
//
//
//
////  public func attach(textField: W3WAutoSuggestTextField) {
////    self.textField = textField
////    updateGeometry()
////    self.view.addSubview(textField)
////  }
////
//
////  public func attach(view: UIView, position: W3WViewPlacement) {
////    self.view.addSubview(view)
////    subViews.add(view: view, position: position)
////    subViews.layout(in: self.view)
////
////    // if a map type button was added, then wire up an action to it
////    if let mapButton = view as? W3WMapTypeButton {
////      mapButton.tapped = { mapType in
////        self.w3wMapView.mapType = mapType
////      }
////    }
////  }
////
//
//  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//    //setNeedsDisplay()
//    //w3wMapView.setNeedsDisplay()
//    mapManager?.redrawAll()
//  }
//
//
//  // MARK:- Accessors
//
//
//  /// This must be called to allow the map to make what3words calls
//  public func set(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
//    mapManager = W3WMapManager(w3w, map: w3wMapView)
//    // w3wMapData = W3WMapData(w3w)
//    // w3wMapView.set(w3w, language: language)
//  }
//
//
//  // MARK: View Layout
//
//
//  func updateGeometry() {
////    var insets = UIEdgeInsets.zero
////    if #available(iOS 11.0, *) {
////      insets = w3wMapView.safeAreaInsets
////    }
//
////    var width = view.frame.size.width - W3WSettings.uiIndent * 4.0 - insets.left - insets.right
////    if view.frame.width > view.frame.height {
////      width = view.frame.size.width / 3.0
////    }
////    let textFrame = CGRect(x: W3WSettings.uiIndent * 2.0 + insets.left, y: W3WSettings.uiIndent * 2.0 + insets.top, width: width, height: 40.0)
////    self.textField?.frame = textFrame
//
////    w3wMapData?.subViews.layout(in: self.view)
//    mapManager?.w3wMapData?.subViews.layout(in: self.view)
//  }
//
//
//  // MARK: UIMapViewDelegates
//
//
////  /// if this is calling for a grid lines renderer, send that, otherwise if the `externalDelegate` is set, call it and return something, otherwise, just send back a generic renderer
////  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
////
////    if let w3wOverlay = mapRenderer(overlay: overlay) {
////      return w3wOverlay
////    }
////
////    return w3wMapData?.externalDelegate?.mapView?(mapView, rendererFor: overlay) ?? MKOverlayRenderer()
////  }
////
////
////  /// hijack this delegate call and update the grid, then pass control to the external delegate
////  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
////    updateGrid()
////    w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
////  }
////
////
////  /// hijack this delegate call and update the grid, then pass control to the external delegate
////  @available(iOS 11, *)
////  public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
////    updateGrid()
////    w3wMapData?.externalDelegate?.mapViewDidChangeVisibleRegion?(mapView)
////  }
////
////
////  /// hijack this delegate call and update the grid, then pass control to the external delegate
////  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
////    updateGrid()
////    w3wMapData?.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
////  }
////
////
////  /// delegate callback to provide a cusomt annotation view
////  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
////    if let a = annotation as? W3WAnnotation {
////      return getMapPinView(annotation: a)
////    }
////
////    return w3wMapData?.externalDelegate?.mapView?(mapView, viewFor: annotation)
////  }
//
//
//  // MARK: Touch Events
//
//
//  /// add the gesture recognizer for tap
//  func attachTapRecognizer() {
//    /// detect user taps
//    let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
//    tap.numberOfTapsRequired = 1
//    tap.numberOfTouchesRequired = 1
//
//    // A kind of tricky thing to make sure double tap doesn't trigger single tap
//    let doubleTap = UITapGestureRecognizer(target: self, action:nil)
//    doubleTap.numberOfTapsRequired = 2
//    w3wMapView.addGestureRecognizer(doubleTap)
//    tap.require(toFail: doubleTap)
//
//    tap.delegate = self
//
//    w3wMapView.addGestureRecognizer(tap)
//  }
//
//
//  /// when the user taps the map this is called and it gets the square info and sends it using the closure
//  @objc func tapped(_ gestureRecognizer : UITapGestureRecognizer) {
//    let location = gestureRecognizer.location(in: w3wMapView)
//    let coordinates = w3wMapView.convert(location, toCoordinateFrom: w3wMapView)
//    mapManager?.w3wMapData?.w3w?.convertTo3wa(coordinates: coordinates, language: mapManager?.w3wMapData?.language ?? W3WSettings.defaultLanguage) { square, error in
//      if let s = square {
//        W3WThread.runOnMain {
//          self.onSquareSelected(s)
//        }
//      }
//    }
//  }
//
//
//  // MARK: UIViewController Events
//
//  override public func viewWillLayoutSubviews() {
//    super.viewWillLayoutSubviews()
//    updateGeometry()
//  }
//
//
//}


#endif











  
  // show a 3 word address on the map
//  public func addAnnotation(_ words: String)                          { mapView.addAnnotation(words)}
//  public func addAnnotation(_ coordinates: CLLocationCoordinate2D)    { mapView.addAnnotation(coordinates)}
//  public func addAnnotation(_ suggestion: W3WSuggestion)              { mapView.addAnnotation(suggestion)}
//  public func addAnnotation(_ square: W3WSquare)                      { mapView.addAnnotation(square)}
//  public func addAnnotations(_ words: [String])                       { mapView.addAnnotations(words)}
//  public func addAnnotations(_ coordinates: [CLLocationCoordinate2D]) { mapView.addAnnotations(coordinates)}
//  public func addAnnotations(_ suggestions: [W3WSuggestion])          { mapView.addAnnotations(suggestions)}
//  public func addAnnotations(_ squares: [W3WSquare])                  { mapView.addAnnotations(squares)}
//
//  // show a 3 word address on the map, and centre the map to show it
//  public func addAndShow(_ words: String)                             { mapView.addAndShow(words)}
//  public func addAndShow(_ coordinates: CLLocationCoordinate2D)       { mapView.addAndShow(coordinates)}
//  public func addAndShow(_ suggestion: W3WSuggestion)                 { mapView.addAndShow(suggestion)}
//  public func addAndShow(_ square: W3WSquare)                         { mapView.addAndShow(square)}
//  public func addAndShow(_ words: [String])                           { mapView.addAndShow(words)}
//  public func addAndShow(_ coordinates: [CLLocationCoordinate2D])     { mapView.addAndShow(coordinates)}
//  public func addAndShow(_ suggestions: [W3WSuggestion])              { mapView.addAndShow(suggestions)}
//  public func addAndShow(_ squares: [W3WSquare])                      { mapView.addAndShow(squares)}
//
//  // remove a 3 word address from the map
//  public func removeAnnotation(_ words: String)                       { mapView.removeAnnotation(words)}
//  public func removeAnnotation(_ suggestion: W3WSuggestion)           { mapView.removeAnnotation(suggestion)}
//  public func removeAnnotation(_ square: W3WSquare)                   { mapView.removeAnnotation(square)}
//  public func removeAnnotations(_ words: [String])                    { mapView.removeAnnotations(words)}
//  public func removeAnnotations(_ suggestions: [W3WSuggestion])       { mapView.removeAnnotations(suggestions)}
//  public func removeAnnotations(_ squares: [W3WSquare])               { mapView.removeAnnotations(squares)}
  
  
  

//  /// set the language
//  public func set(language: String) { mapView.set(language: language) }
//
//  /// set the center of the map
//  public func set(center: W3WSquare)                      { mapView.set(center: center) }
//  public func set(center: W3WSuggestion)                  { mapView.set(center: center) }
//  public func set(center: String)                         { mapView.set(center: center) }
//  public func set(center: CLLocationCoordinate2D)         { mapView.set(center: center) }
//
//  /// set the minimum visible area of the map
//  public func set(latitudeSpanMeters: Double, longitudeSpanMeters: Double) { mapView.set(latitudeSpanMeters: latitudeSpanMeters, longitudeSpanMeters: longitudeSpanMeters) }
//  public func set(altitude: Double)                            { mapView.set(altitude: altitude) }
//  public func set(radius: Double)                              { mapView.set(radius: radius) }
//  public func set(diameter: Double)                            { mapView.set(diameter: diameter) }
//
//  /// set the center of the map and  the minimum visible area of the map
//  public func set(center: W3WSquare, altitude: Double)     { mapView.set(center: center, altitude: altitude) }
//  public func set(center: W3WSuggestion, altitude: Double) { mapView.set(center: center, altitude: altitude) }
//  public func set(center: W3WSquare, radius: Double)       { mapView.set(center: center, radius: radius) }
//  public func set(center: W3WSuggestion, radius: Double)   { mapView.set(center: center, radius: radius) }
//  public func set(center: W3WSquare, diameter: Double)     { mapView.set(center: center, diameter: diameter) }
//  public func set(center: W3WSuggestion, diameter: Double) { mapView.set(center: center, diameter: diameter) }
//
//  /// set the 3D camera of the map view
//  public func camera(lookingAt: W3WSquare, from: W3WSquare, withAltitude: Double) { mapView.camera(lookingAt: lookingAt, from: from, withAltitude: withAltitude) }
//  public func camera(lookingAt: String,    from: String,    withAltitude: Double) { mapView.camera(lookingAt: lookingAt, from: from, withAltitude: withAltitude) }
//
//  /// show a 3 word address on the map
//  public func show(_ square: W3WSquare)                   { mapView.show(square) }
//  public func show(_ suggestion: W3WSuggestion)           { mapView.show(suggestion) }
//  public func show(_ words: String)                       { mapView.show(words) }
//  public func show(_ coordinates: CLLocationCoordinate2D) { mapView.show(coordinates) }
//
//  /// remove a 3 word address from a map
//  public func hide(_ square: W3WSquare)                   { mapView.hide(square) }
//  public func hide(_ suggestion: W3WSuggestion)           { mapView.show(suggestion) }
//  public func hide(_ words: String)                       { mapView.hide(words) }
//  public func hide(_ coordinates: CLLocationCoordinate2D) { mapView.show(coordinates) }
//
//  /// remove all anootations from the map
//  public func hideAll() {
//    mapView.hideAll()
//  }

  


//  // MARK: Delegate
//
//
//  /// send map touches as W3WSquares
//  public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    if let coordinate = view.annotation?.coordinate {
//      self.mapView.w3wMapData?.w3w?.convertTo3wa(coordinates: coordinate, language: self.mapView.w3wMapData?.language ?? W3WSettings.defaultLanguage) { square, error in
//        if let s = square {
//          W3WThread.runOnMain {
//            self.onAnnotationSelected(s)
//          }
//        }
//      }
//    }
//  }

  
