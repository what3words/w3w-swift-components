//
//  File.swift
//  
//
//  Created by Dave Duprey on 25/11/2020.
//
#if !os(macOS)

import Foundation
import UIKit
import W3WSwiftApi


/// view to display an erro
class W3WTextErrorView: W3WMessageView {
  
  var label: UILabel? = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0)))
  
  
  /// initialize the UI
  override func setupUI() {
    updateGeometry()
    
    if let l = label {
      addSubview(l)
    }

    updateColours()
  }
  
  
  override func updateColours() {
    backgroundColor = W3WSettings.color(named: "ErrorBackground")
    layer.borderColor = W3WSettings.color(named: "BorderColor").cgColor
    layer.borderWidth = 0.5
    
    let attributes = [NSAttributedString.Key.foregroundColor : W3WSettings.color(named: "ErrorTextColor")]
    label?.attributedText = NSAttributedString(string: label?.text ?? "?", attributes: attributes)

    tintColor = .clear
  }
  
  
  override func updateGeometry() {
    var labelFrame = frame
    labelFrame.origin = CGPoint(x: W3WSettings.componentsIconPadding, y: 0.0)
    labelFrame.size.width -= W3WSettings.componentsIconPadding * 2.0
    
    //label = UILabel(frame: labelFrame)
    label?.frame = labelFrame
    label?.adjustsFontSizeToFitWidth = true
    label?.minimumScaleFactor = 0.5
  }
  
  
  /// sets the error as an atributed string
  func set(error: NSAttributedString) {
    label?.attributedText = error
  }
  
  
  /// sets the error as plain text
  func set(error: String) {
    label?.text = error
  }
  
 
}


#endif
