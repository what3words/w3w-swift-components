


//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit


@IBDesignable
public class W3WVoiceIconView: W3WInteractiveDrawingView {
  
  @IBInspectable public var iconColour: UIColor   = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
  @IBInspectable public var lineWidth: NSNumber?  = nil

  public var alignment = W3WHorizontalAlignment.center

  /// draw the icon for the speech bubble in the middle
  /// - Parameters:
  ///     - centre: the centre of the icon
  ///     - radius: the radius of the circle it's being placed in
  func voiceIcon(centre: CGPoint, radius:CGFloat, colour: UIColor, weight: CGFloat? = nil) {
    
    // sizes and places
    let breakAngle = 0.75 * CGFloat.pi
    let breakSize  =  0.1 * CGFloat.pi
    let corner     = CGPoint(x: centre.x - radius, y: centre.y + radius)
    let x_offset   = radius * 0.13
    let y_offset   = radius * 0.4
    let spacing    = radius * 0.375
    
    let lineWidth  = weight == nil ? radius * 0.13 : weight!
    
    // draw half of the arc
    let path = UIBezierPath(arcCenter: centre, radius: radius, startAngle: 0.0, endAngle: breakAngle + breakSize, clockwise: false)
    
    // add one line of the point
    path.addLine(to: corner)
    
    // draw the other half of the arc, and by closing this here, the other line of the point gets created automatically
    path.addArc(withCenter: centre, radius: radius, startAngle: breakAngle - breakSize, endAngle: 0.0, clockwise: false)
    
    // draw the three slashes in the middle
    roundedLine(p0: CGPoint(x: centre.x + x_offset - spacing, y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset - spacing, y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset,           y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset,           y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset + spacing, y: centre.y - y_offset), p1: CGPoint(x: centre.x - x_offset + spacing, y: centre.y + y_offset), colour: colour, lineWidth: lineWidth)
    
    // choose the colour based on if the microphone is 'engaged' (opposite the circle colours)
    colour.setStroke()
    
    path.lineWidth = lineWidth
    path.stroke()
    path.close()
  }
  

  /// draw the microphone
  override func make(_ rect: CGRect) {
    let weight:CGFloat? = lineWidth == nil ? nil : CGFloat(lineWidth!.floatValue)
    
    var alignedRect = rect
    
    if alignment == .leading {
      alignedRect = CGRect(x: 0.0, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    } else if alignment == .trailing {
      alignedRect = CGRect(x: rect.size.width - rect.size.height, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    }
    
    voiceIcon(centre: CGPoint(x: alignedRect.midX, y: alignedRect.midY), radius: min(alignedRect.width, alignedRect.height) / 2.0, colour: iconColour, weight: weight)
  }
  
  
}

