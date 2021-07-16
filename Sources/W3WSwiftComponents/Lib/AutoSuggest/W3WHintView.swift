//
//  File.swift
//  
//
//  Created by Dave Duprey on 25/11/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


typealias W3WHintTapped = () ->()


/// view to display an erro
class W3WHintView: UIView {

  var onTapped: W3WHintTapped = { }
  
  var hintLabel: UILabel?
  var titleLabel: UILabel?

  
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
    labelFrame.origin = CGPoint(x: W3WSettings.componentsIconPadding, y: W3WSettings.componentsIconPadding)
    labelFrame.size.width -= W3WSettings.componentsIconPadding * 2.0
    labelFrame.size.height = frame.height * 0.35
    
    titleLabel = UILabel(frame: labelFrame)
    hintLabel?.font = UIFont.systemFont(ofSize: labelFrame.size.height, weight: .light)
    titleLabel?.adjustsFontSizeToFitWidth = true
    titleLabel?.minimumScaleFactor = 0.5
    if let l = titleLabel {
      addSubview(l)
    }
    
    labelFrame.origin.y = labelFrame.size.height
    labelFrame.size.height = frame.height - labelFrame.origin.y
    hintLabel = UILabel(frame: labelFrame)
    hintLabel?.font = UIFont.systemFont(ofSize: labelFrame.size.height * 0.4, weight: .semibold)
    hintLabel?.adjustsFontSizeToFitWidth = true
    hintLabel?.minimumScaleFactor = 0.5
    if let l = hintLabel {
      addSubview(l)
    }
    
    backgroundColor = W3WSettings.componentsHintBackground
    layer.borderColor = W3WSettings.componentsBorderColor.cgColor
    layer.borderWidth = 0.5
    
    // create a gesture recognizer (tap gesture)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHappened(recognizer:)))
    tapGesture.cancelsTouchesInView = true
    addGestureRecognizer(tapGesture)
  }
  
  
  /// called when the user touches the center of the circle
  @objc func tapHappened(recognizer: UITapGestureRecognizer) {
    onTapped()
  }

  
  /// sets the error as an atributed string
  func set(title: String, hint: NSAttributedString) {
    titleLabel?.text = title
    hintLabel?.attributedText = hint
  }
  
  
  /// sets the error as plain text
  func set(title: String, hint: String) {
    titleLabel?.text = title
    hintLabel?.text = hint
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
