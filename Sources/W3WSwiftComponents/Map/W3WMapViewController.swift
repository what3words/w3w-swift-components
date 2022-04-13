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


// MARK:- W3WMapViewController


open class W3WMapViewController: UIViewController, UIGestureRecognizerDelegate, W3WMapViewProtocol {

  /// called when the user taps a square in the map
  public var onSquareSelected: (W3WSquare) -> () = { _ in }
  
  /// called when the user taps a square that has a marker added to it
  public var onMarkerSelected: (W3WSquare) -> () = { _ in }
  
  /// returns the error enum for any error that occurs
  public var onError: W3WMapErrorResponse = { _ in }

  /// allows other things like button s to be placed on the map
  var subViews = W3WSubviewManager()

  
  // MARK:- Init
  
  
  public convenience init(_ w3w: W3WProtocolV3, language: String = W3WSettings.defaultLanguage) {
    self.init()
    set(w3w, language: language)
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
    mapHelper = W3WMapHelper(w3w, map: w3wMapView, language: language)
    
    // let map helper take care of the delegate callbacks
    w3wMapView.delegate = mapHelper
    
    // if a marker was tapped
    mapHelper?.onMarkerSelected = { square in
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
    subViews.layout(in: w3wMapView)
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
    subViews.add(view: textField, position: .topCenter)
    subViews.layout(in: w3wMapView)
  }
  
  
  public func attach(view: UIView, position: W3WViewPlacement) {
    w3wMapView.addSubview(view)
    subViews.add(view: view, position: position)
    subViews.layout(in: w3wMapView)
    
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



#endif

