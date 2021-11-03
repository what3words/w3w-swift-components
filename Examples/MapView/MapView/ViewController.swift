//
//  ViewController.swift
//  MapView
//
//  Created by Dave Duprey on 08/10/2021.
//

import UIKit
import MapKit
import W3WSwiftApi
import W3WSwiftComponents


/// We created W3WMapView as a quick and dirty way to quickly get
/// what3words functionality into your app.  Simply replace your
/// MKMapView with W3WMapView, and your app should behave the same
/// as before except it will draw what3words grid lines, and have
/// some new functions available, like `show("filled.count.soap")`.
/// Apple does not reccomend deriving new objects from MKMapView
/// as it's interface could change in the future, so view this as a
/// quick and dirty way to get the functionality into your app. The
/// better approach would be to use `W3WMapHelper` which is designed
/// to fit nicely into your `MKMapViewDelegate` conforming class,
/// presumably a UIViewController.


class ViewController: UIViewController {
  
  let api = What3WordsV3(apiKey: "YourApiKey")
  
  /// assign the `MKMapView` as the default view
  public override func loadView() {
    view = W3WMapView(api)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // if the is an error then put it into an alert
    mapView.onError = { error in self.showError(error: error) }
    
    // show a square on the map
    mapView.show("filled.count.soap", camera: .zoom)
    
    // try these ones too!
    //mapView.show(["filled.count.soap", "digits.return.object"])
    //mapView.show(["input.caring.brain", "snitch.straw.coaching", "graphics.swam.winded"])
    
    // Or, show the results of an autosuggest call:
    //api.autosuggest(text: "filled.count.r", options: [W3WOption.clipToCountry("GB"), W3WOption.numberOfResults(25)]) { suggestions, error in
    //  if let e = error {
    //    self.showError(error: e)
    //  }
    //
    //  self.mapView.show(suggestions)
    //}
  }
  
  
  /// Convenience wrapper to get view as W3WMapView
  public var mapView: W3WMapView {
    return view as? W3WMapView ?? W3WMapView(api)
  }
  
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    DispatchQueue.main.async { self.present(alert, animated: true) }
  }
  
  
}

