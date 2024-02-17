//
//  ViewController.swift
//  MapComponent
//
//  Created by Dave Duprey on 08/10/2021.
//

import UIKit
import W3WSwiftCore
import W3WSwiftComponents


/// This test `W3WMapViewController` which uses functionality
/// from a number of the other classes in the package


class ViewController: W3WMapViewController {
  
  var apiKey: String = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let apikey = ProcessInfo.processInfo.environment["PROD_API_KEY"] {
      self.apiKey = apikey
    } else if let apikey = getApikeyFromFile() {
      self.apiKey = apikey
    } else {
      print("Environment variable APIKEY must be set")
      abort()
    }
    
    let api = What3WordsV3(apiKey: apiKey)
    
    // give the map access to the API
    set(api)
    
    // when a point on the map is touched, highlight that square, and put it's word into the text field
    self.onSquareSelected = { square in
      self.addMarker(at: square, camera: .center)
    }
    
    // make a satelite/map button, and attach it
    let button = W3WMapTypeButton()
    attach(view: button, position: .bottomRight)
    
    // if the is an error then put it into an alert
    onError = { error in self.showError(error: error) }
    
    addMarker(at: "filled.count.soap", camera: .zoom)
  }
  
  
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    }
  }
  
  
  func getApikeyFromFile() -> String? {
    var apikey: String? = nil
    
    let url = URL(fileURLWithPath: "/tmp/key.txt")
    if let key = try? String(contentsOf: url, encoding: .utf8) {
      apikey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    return apikey
  }
  
  
}

