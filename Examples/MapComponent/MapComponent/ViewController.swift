//
//  ViewController.swift
//  MapComponent
//
//  Created by Dave Duprey on 08/10/2021.
//

import UIKit
import W3WSwiftApi
import W3WSwiftComponents


/// This demonstrates `W3WMapViewController` which is a high level component
/// that has easy to use what3words functionality.   If you already have a map in your
/// application then you will want to use `W3WMapHelper` to add the what3words
/// grid and  pins to your map.  Find the example called MapHelper.  If you have no map in your
/// app and want to quickly include on with some default behaviours then it's easy
/// to include this one.


class ViewController: W3WMapViewController {
  
  let api = What3WordsV3(apiKey: "Your API Key")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // give the map access to the API
    set(api)
    
    // make an autosuggest text field with voice option, and attach it to the view (voice functionality requires API key permissions, contact what3words to enable this - https://accounts.what3words.com/overview)
    let textField = W3WAutoSuggestTextField(api)
    textField.set(voice: true)
    attach(textField: textField)
    
    // when an autosuggest suggestion is selected from the text field, show it on the map and clear previous selections
    textField.onSuggestionSelected = { suggestion in
      self.hideAll()
      self.show(suggestion, camera: .zoom)
    }
    
    // when a point on the map is touched, highlight that square, and put it's word into the text field
    self.onSquareSelected = { square in
      self.show(square, camera: .center)
      textField.set(display: square)
    }
    
    // make a satelite/map button, and attach it
    let button = W3WMapTypeButton()
    attach(view: button, position: .bottomRight)
    
    // if the is an error then put it into an alert
    onError = { error in self.showError(error: error) }
    
    show("filled.count.soap", camera: .zoom)
  }
  
  
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    DispatchQueue.main.async { self.present(alert, animated: true) }
  }
  
  
}

