//
//  File.swift
//  
//
//  Created by Dave Duprey on 25/11/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


/// view to display an erro
class W3WTextErrorView: UIView {
  
  var label: UILabel?
  
  // Init
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  
  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    setupUI()
  }

  
  /// initialize the UI
  func setupUI() {
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }

    var labelFrame = frame
    labelFrame.origin = CGPoint(x: W3WSettings.componentsIconPadding, y: 0.0)
    labelFrame.size.width -= W3WSettings.componentsIconPadding * 2.0
    
    label = UILabel(frame: labelFrame)
    label?.adjustsFontSizeToFitWidth = true
    label?.minimumScaleFactor = 0.5
    if let l = label {
      addSubview(l)
    }
    
    backgroundColor = W3WSettings.color(named: "ErrorBackground")
    layer.borderColor = W3WSettings.color(named: "BorderColor").cgColor
    layer.borderWidth = 0.5
  }
  
  
  /// sets the error as an atributed string
  func set(error: NSAttributedString) {
    label?.attributedText = error
  }
  
  
  /// sets the error as plain text
  func set(error: String) {
    label?.text = error
  }
  
  
  /// draws in some diesign elements
  override func draw(_ rect: CGRect) {
    let cgContext = UIGraphicsGetCurrentContext()
    cgContext?.move(to: CGPoint(x: rect.minX, y: rect.minY))
    cgContext?.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    cgContext?.setStrokeColor(tintColor.cgColor)
    cgContext?.setLineWidth(3.0)
    cgContext?.strokePath()
  }
  
}
