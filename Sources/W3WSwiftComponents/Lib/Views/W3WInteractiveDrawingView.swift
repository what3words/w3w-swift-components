//
//  W3DrawingView.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 13/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit


/// W3WDrawingView turned into a button
open class W3WInteractiveDrawingView : W3WDrawingView {

  /// closure to recieve tap events
  public var tapped: () -> () = {}
  
  /// set up all the UI stuff, called from the init() functions
  override public func instantiateUIElements() {
    backgroundColor = .clear
    
    // create a gesture recognizer (tap gesture)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHappened(recognizer:)))
    tapGesture.cancelsTouchesInView = true
    addGestureRecognizer(tapGesture)
  }
  

  /// called when the user touches the center of the circle
  @objc func tapHappened(recognizer: UITapGestureRecognizer) {
    tapped()
  }
  
  
}
