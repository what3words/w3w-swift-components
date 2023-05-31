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

    // assign a code block to execute when the user has selected an address
    textField.onSuggestionSelected = { suggestion in
      print("User chose:", suggestion.words ?? "")
    }
      

    // the exact error can be captured using onError for whatever purpose you might have
    textField.onError = { error in
    self.showError(error: error)
    }
    
    // place in the view
    view.addSubview(textField)
  }

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

