//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import W3WSwiftApi


/// draws a voice icon
@IBDesignable
open class W3WVoiceIconView: W3WInteractiveDrawingView {
  
  @IBInspectable public var lineWidth: NSNumber?  = nil

  public var alignment = W3WHorizontalAlignment.center

  /// draw the icon for the speech bubble in the middle
  /// - Parameters:
  ///     - centre: the centre of the icon
  ///     - radius: the radius of the circle it's being placed in
  func voiceIcon(centre: CGPoint, radius:CGFloat, colour: UIColor, weight: CGFloat? = nil) {
    
    // sizes and places
    let lineWidth       = weight == nil ? radius * 0.1 : weight!
    let radiusAdjusted = radius - lineWidth // radius brought in the size of the line to make sure it doesn't overrun the image border
    let breakAngle    = 0.75 * CGFloat.pi
    let breakSize    =  0.1 * CGFloat.pi
    let corner      = CGPoint(x: centre.x - radiusAdjusted, y: centre.y + radiusAdjusted)
    let x_offset    = radiusAdjusted * 0.13
    let y_offset     = radiusAdjusted * 0.375
    let spacing       = radiusAdjusted * 0.375
    

    // draw half of the arc
    let path = UIBezierPath(arcCenter: centre, radius: radiusAdjusted, startAngle: 0.0, endAngle: breakAngle + breakSize, clockwise: false)
    
    // add one line of the point
    path.addLine(to: corner)
    
    // draw the other half of the arc, and by closing this here, the other line of the point gets created automatically
    path.addArc(withCenter: centre, radius: radiusAdjusted, startAngle: breakAngle - breakSize, endAngle: 0.0, clockwise: false)
    
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
  override public func make(_ rect: CGRect) {
    var alignedRect = rect
    
    if alignment == .leading {
      alignedRect = CGRect(x: 0.0, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    } else if alignment == .trailing {
      alignedRect = CGRect(x: rect.size.width - rect.size.height, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    }

    let centre = CGPoint(x: alignedRect.midX, y: alignedRect.midY)
    let radius = min(alignedRect.width, alignedRect.height) / 2.0
    let weight:CGFloat = lineWidth == nil ? radius * 0.1 : CGFloat(lineWidth!.floatValue)

    voiceIcon(centre: centre, radius: radius - weight, colour: W3WSettings.color(named: "VoiceIconColor"), weight: weight)
  }
  
  
}

