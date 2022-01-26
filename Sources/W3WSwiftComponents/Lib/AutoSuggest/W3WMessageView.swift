//
//  File.swift
//  
//
//  Created by Dave Duprey on 11/08/2021.
//
#if !os(macOS) && !os(watchOS)

import Foundation
import UIKit


class W3WMessageView: UIView {
  
  
  // Init
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  
  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    setupUI()
  }

  
  func setupUI() {
  }
  
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    updateColours()
  }

  
  func updateColours() {
  }
   

  func updateGeometry() {
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

#endif
