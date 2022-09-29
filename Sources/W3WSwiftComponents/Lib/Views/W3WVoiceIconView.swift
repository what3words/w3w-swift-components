//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
#if !os(macOS) && !os(watchOS)

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
  func voiceIcon(centre: CGPoint, radius:CGFloat, colour: UIColor, weight: CGFloat? = nil, filled: Bool = false) {

    let lineWidth         = weight == nil ? radius * 0.09 : weight!

    let radiusAdjusted    = radius * 0.6 - lineWidth // radius brought in the size of the line to make sure it doesn't overrun the image border
    let outerRadius       = radiusAdjusted * 1.5
    let micCentreOffsetY  = radiusAdjusted * -1.2
    let micMiddleHeight   = radiusAdjusted * -0.2
    let stemHeight        = radiusAdjusted * 0.8
    let rimHeight         = radiusAdjusted * -0.5

    let x_offset          = radiusAdjusted * 0.15
    let y_offset          = radiusAdjusted * 0.4
    let spacing           = radiusAdjusted * 0.42
    let slash_y_adjust    = radiusAdjusted * -0.65

    let centreOfTopArc    = CGPoint(x: centre.x, y: centre.y + micCentreOffsetY)
    let centreOfBottomArc = CGPoint(x: centre.x, y: centre.y + micMiddleHeight)

    let path = UIBezierPath(arcCenter: centreOfTopArc, radius: radiusAdjusted, startAngle: 0.0, endAngle: .pi, clockwise: false)

    path.move(to: CGPoint(x: centre.x - radiusAdjusted, y: centreOfTopArc.y))
    path.addLine(to: CGPoint(x: centre.x - radiusAdjusted, y: centreOfBottomArc.y))

    path.addArc(withCenter: CGPoint(x: centre.x, y: centre.y + micMiddleHeight), radius: radiusAdjusted, startAngle: .pi, endAngle: 2.0 * .pi, clockwise: false)

    path.addLine(to: CGPoint(x: centre.x + radiusAdjusted, y: centreOfTopArc.y))

    if filled {
      UIColor.clear.setStroke()
      colour.setFill()
      path.fill()
    } else {
      colour.setStroke()
      path.lineWidth = lineWidth
      path.stroke()
    }
    path.close()

    let path2 = UIBezierPath(arcCenter: centreOfBottomArc, radius: outerRadius, startAngle: .pi, endAngle: .pi * 2.0, clockwise: false)

    colour.setStroke()
    path2.lineWidth = lineWidth
    path2.stroke()

    path2.close()

    roundedLine(p0: CGPoint(x: centre.x, y: centreOfBottomArc.y + outerRadius), p1: CGPoint(x: centre.x, y: centreOfBottomArc.y + outerRadius + stemHeight), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x - stemHeight, y: centreOfBottomArc.y + outerRadius + stemHeight), p1: CGPoint(x: centre.x + stemHeight, y: centreOfBottomArc.y + outerRadius + stemHeight), colour: colour, lineWidth: lineWidth)

    var slashColor = colour
    if filled {
      slashColor = W3WColorScheme.isLight(colour: colour) ? .black : .white
    }
    
    // slashes
    roundedLine(p0: CGPoint(x: centre.x + x_offset - spacing, y: centre.y - y_offset + slash_y_adjust), p1: CGPoint(x: centre.x - x_offset - spacing, y: centre.y + y_offset + slash_y_adjust), colour: slashColor, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset,           y: centre.y - y_offset + slash_y_adjust), p1: CGPoint(x: centre.x - x_offset,           y: centre.y + y_offset + slash_y_adjust), colour: slashColor, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + x_offset + spacing, y: centre.y - y_offset + slash_y_adjust), p1: CGPoint(x: centre.x - x_offset + spacing, y: centre.y + y_offset + slash_y_adjust), colour: slashColor, lineWidth: lineWidth)
    
    // cup rim
    roundedLine(p0: CGPoint(x: centre.x - outerRadius, y: centreOfBottomArc.y), p1: CGPoint(x: centre.x - outerRadius, y: centre.y + rimHeight), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: centre.x + outerRadius, y: centreOfBottomArc.y), p1: CGPoint(x: centre.x + outerRadius, y: centre.y + rimHeight), colour: colour, lineWidth: lineWidth)
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


#endif
