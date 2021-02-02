//
//  W3DrawingView.swift
//  CoordinatorTemplate
//
//  Created by Dave Duprey on 13/07/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit


public enum W3WHorizontalAlignment {
  case leading
  case center
  case trailing
}



public class W3WDrawingView: UIView {

  var insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  
  
  public convenience init() {
    self.init(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
  }
  
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    instantiateUIElements()
  }
  
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    instantiateUIElements()
  }
  
  
  /// set up all the UI stuff, called from the init() functions
  func instantiateUIElements() {
    backgroundColor = .clear
  }
  
  
  func set(padding: CGFloat) {
    insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
  }
  
  
  func set(padding: Double) {
    set(padding: CGFloat(padding))
  }
  
  
  /// draw a circle
  /// - Parameters:
  ///     - centre: the centre of the circle
  ///     - radius: the radius of the circle
  ///     - transparancy: the amount to set the transparancy relative to the current self.micOnColour
  func circle(centre: CGPoint, radius:CGFloat, colour: UIColor) {
    let path = UIBezierPath(arcCenter: centre, radius: radius, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: true)
    
    // choose the colour based on if the microphone is 'engaged'
    colour.setFill()
    
    path.fill()
    path.close()
  }
  

  func roundedLine(p0: CGPoint, p1: CGPoint, colour: UIColor, lineWidth: CGFloat) {
    let path = UIBezierPath()

    path.move(to: p0)
    path.addLine(to: p1)
    circle(centre: p0, radius: lineWidth / 2.0, colour: colour)
    circle(centre: p1, radius: lineWidth / 2.0, colour: colour)

    colour.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
    path.close()
  }
  
  
  func rectangle(rect: CGRect, colour: UIColor) {
    let path = UIBezierPath(rect: rect)
    
    colour.setFill()
    
    path.fill()
    path.close()
  }
  
  
  func slashes(rect: CGRect, colour: UIColor, width: CGFloat? = nil) {
    
    let size = min(rect.width, rect.height) * 0.9
    
    //let centre = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
    
    // find the centre
    let centre = CGPoint(x:rect.midX, y:rect.midY)
    
    var lineWidth = size * (2.0 / 32.0)
    if let w = width {
      lineWidth = w
    }
    
    // draw the three slashes in the middle
    let x_offset = size * (6.0 / 32.0) //0.13
    let y_offset = size * 0.5 // 0.4
    let spacing  = size * (11.0 / 32.0) //0.3
    
    roundedLine(p0: CGPoint(x: centre.x + x_offset - spacing, y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset - spacing, y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset,           y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset,           y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset + spacing, y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset + spacing, y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
  }
  

  
  
  public func asImage() -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    self.draw(self.bounds)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  
  func make(_ rect: CGRect) {
  }
  
  /// draw the microphone
  public override func draw(_ rect: CGRect) {
    make(rect.inset(by: insets))
  }

  
}
