///
//  ViewController.swift
//  TextField
//
//  Created by Dave Duprey on 26/11/2020.
//

import UIKit
import W3WSwiftApi
import W3WSwiftComponents
import CoreLocation
import Foundation


class ViewController: UIViewController {
    let testData = ClippingSettings()
    var apiKey: String {
          get {
              if let api = UserDefaults.standard.string(forKey: "ApiKey")
              {
                  return api
              }
              return ""
          }
      }
      
    override func viewDidLoad() {
    super.viewDidLoad()

    let testData = ClippingSettings()

      var clipppingOptions : [W3WOption]
      {
          if let shape = UserDefaults.standard.string(forKey: "Clipping")
          {
              if let clipping = ClippingType(rawValue: shape)
              {
                  return testData.getClippingOptions(option : clipping)
              }
          }
          return testData.getClippingOptions(option : ClippingType.NoClipping)
      }
      
    let textField = W3WAutoSuggestTextField(frame: CGRect(x: 16.0, y: (UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 64.0) + 16.0, width: view.frame.size.width - 32.0, height: 32.0))
    textField.accessibilityIdentifier = "w3wTextField"
               
    // assign the API to it
    let api = What3WordsV3(apiKey: apiKey)
    textField.set(api)
    textField.set(options: clipppingOptions)
    // turn on voice support
    textField.set(voice: true)
    textField.set(language: "en")
    textField.suggestionSelected = { suggestion in
        print("User chose:", suggestion.words ?? "")
    }
      

    // the exact error can be captured using onError for whatever purpose you might have
    textField.onError = { error in
    self.showError(error: error)
    }
    
    // place in the view
    view.addSubview(textField)
  }

    /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }
}

