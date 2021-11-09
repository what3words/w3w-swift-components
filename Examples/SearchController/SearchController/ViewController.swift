//
//  ViewController.swift
//  SearchController
//
//  Created by Dave Duprey on 13/11/2020.
//

import UIKit
import W3WSwiftApi
import W3WSwiftComponents


class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // make the API
    let apiKey = "YourApiKey"
    let api = What3WordsV3(apiKey: apiKey)
    
    // make a search field
    let search = W3WAutoSuggestSearchController()
    
    // assign the api to it
    search.set(api)
    
    // turn on voice support
    search.set(voice: true)
    
    // assign a code block to execute when a suggestion is chosen
    search.onSuggestionSelected = { suggestion in
      print("Selected: ", suggestion.words ?? "none")
    }
    
    // the exact error can be captured using onError for whatever purpose you might have
    search.onError = { error in
      self.showError(error: error)
    }

    // add to the navigation controller
    navigationItem.searchController = search
  }

  
  
  /// display an error using a UIAlertController, error messages conform to CustomStringConvertible
  func showError(error: Error) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    }
  }

}

