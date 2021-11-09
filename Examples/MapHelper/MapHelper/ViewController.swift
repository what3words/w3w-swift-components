//
//  ViewController.swift
//  MapHelper
//
//  Created by Dave Duprey on 08/10/2021.
//

import UIKit
import MapKit
import W3WSwiftApi
import W3WSwiftComponents


/// If you have a ViewController that has a map, `W3WMapHelper` provides convenience
/// functions to add to your `MKMapViewDelegate` functions for what3words
/// grid and pin annotations to appear on your map.
/// This example shows where you would place the calls, and how to instantiate the
/// `W3WMapHelper`.


class ViewController: UIViewController, MKMapViewDelegate {
  
  let api = What3WordsV3(apiKey: "Your API Key")
  var mapHelper: W3WMapHelper!
  
  
  /// Convenience wrapper to get view as MKMapView; it is set in the storyboard.
  public var mapView: MKMapView {
    return view as? MKMapView ?? MKMapView()
  }
  
  
  /// assign the `MKMapView` to `view` when the time comes
  public override func loadView() {
    view = MKMapView()
  }

  
  /// Good 'ol viewDidLoad...
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // make a mapHelper
    mapHelper = W3WMapHelper(api, map: mapView)
    
    // if the is an error then put it into an alert
    mapHelper.onError = { error in self.showError(error: error) }
    
    // assign this ViewController as the delegate for the map (you can set `mapHelper` as the delegate instead of `self` if you are not interested in MKMapViewDelegate callbacks)
    mapView.delegate = self
    
    // show a square on the map
    mapHelper.show("filled.count.soap")

    // other things to try instead
    //mapHelper.show("filled.count.soap", camera: .center)
    //mapHelper.show("daring.lion.race", camera: .none, color: .blue, style: .pin)

  }
  
  
  // MARK: MKMapViewDelegate
  
  // mapHelper also contains all the following MKMapViewDelegate functions, so it is possible
  // to just set `mapView.delegate = mapHelper` in `viewDidLoad` and remove the following code.
  // You might do this if you are not interested in any MKMapViewDelegate events.
  // Most implementations are likely interested in some events so this shows how to use mapHelper
  // functions in your MKMapViewDelegate functions
  
  
  /// Tells the delegate that the map view's visible region changed.
  @available(iOS 11, *)
  public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    mapHelper.updateMap() // Updates the map view with annotations and lines
  }
  
  
  /// Tells the delegate that the region displayed by the map view is about to change.
  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    mapHelper.updateMap() // Updates the map view with annotations and lines
  }
  
  
  /// Tells the delegate that the region displayed by the map view just changed.
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    mapHelper.updateMap() // Updates the map view with annotations and lines
  }
  
  
  /// Asks the delegate for a renderer object to use when drawing the specified overlay.
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    // if it is a what3words grid overlay, this gets a renderer, otherwise it returns nil and you can provide your own
    if let w3wOverlay = mapHelper.mapRenderer(overlay: overlay) {
      return w3wOverlay
    }
    // otherwise return a default or your own renderer
    return MKOverlayRenderer()
  }
  
  
  /// Returns the view associated with the specified annotation object.
  /// you will probably be using your own annotations, in which case, you need not include this
  /// and you would pass back your own views for the pins.  You can check if the annotation
  /// is a w3w one using something like:  `if let a = annotation as? W3WAnnotation {`
  /// and from there you can get the three word address: `a.square.words` and the coordinates etc...
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // if the annotion is a what3words one, this gets a renderer, otherwise it returns nil and you can provide your own
    if let a = mapHelper.getMapAnnotationView(annotation: annotation) {
      return a
    }
    // otherwise return nothing or your own annotation view
    return nil
  }
  
  // MARK: Error UI
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  
}

