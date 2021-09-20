//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit
import W3WSwiftApi


@IBDesignable
public class W3WCheckIconView: W3WDrawingView {
  
  /// draw the icon for the speech bubble in the middle
  /// - Parameters:
  ///     - centre: the centre of the icon
  ///     - radius: the radius of the circle it's being placed in
  func checkIcon(centre: CGPoint, radius:CGFloat, colour: UIColor, weight: CGFloat? = nil) {
    
    let lineWidth  = weight == nil ? radius * 0.1 : weight!
    let radiusAdjusted = radius - lineWidth // radius brought in the size of the line to make sure it doesn't overrun the image border

    // draw half of the arc
    let path = UIBezierPath(arcCenter: centre, radius: radiusAdjusted, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
        
    let checkBottom = CGPoint(x: centre.x - radiusAdjusted * (3.0 / 12.0), y: centre.y + radiusAdjusted * (5.0 / 12.0))
    let checkRight  = CGPoint(x: centre.x + radiusAdjusted * (6.0 / 12.0), y: centre.y - radiusAdjusted * (4.5 / 12.0))
    let checkLeft   = CGPoint(x: centre.x - radiusAdjusted * (6.0 / 12.0), y: centre.y + radiusAdjusted * (2.0 / 12.0))

    // draw the check
    roundedLine(p0: checkBottom, p1: checkLeft, colour: colour, lineWidth: lineWidth)
    roundedLine(p0: checkBottom, p1: checkRight, colour: colour, lineWidth: lineWidth)
    
    // choose the colour based on if the microphone is 'engaged' (opposite the circle colours)
    colour.setStroke()
    
    path.lineWidth = lineWidth
    path.stroke()
    path.close()
    
  }
  
  
  // MARK: Drawing
  
  override public func make(_ rect: CGRect) {
    // gets a radius for the innermost circle
    let radius = min(rect.size.width, rect.size.height) / 2.0
    
    // find the centre
    let centre = CGPoint(x:rect.midX, y:rect.midY)
    let weight = radius * 0.1 // (2.0 / 13.0)
    
    checkIcon(centre: centre, radius: radius - weight, colour: W3WSettings.color(named: "CheckMarkColor"), weight: weight)
  }
  
  
}

