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



@IBDesignable
public class W3WDashes: W3WDrawingView {
  
  public var alignment = W3WHorizontalAlignment.leading
  
  
  // MARK: Drawing
    
  
  /// draw the microphone
  public override func make(_ rect: CGRect) {

    let size    = rect.height * 0.2
    let spacing = size * 2.0
    let y       = rect.height / 2.0
    
    let dash1p1 = CGPoint(x: size * 2.0, y: y)
    let dash3p2 = CGPoint(x: rect.width - size * 4.0, y: y)

    let oneThird = (dash3p2.x - dash1p1.x - spacing) / 3.0
    let dot1 = CGPoint(x: dash1p1.x + oneThird, y: y)
    let dot2 = CGPoint(x: dash3p2.x - oneThird, y: y)

    let dash1p2 = CGPoint(x: dot1.x - spacing, y: y)
    let dash2p1 = CGPoint(x: dot1.x + spacing, y: y)
    let dash2p2 = CGPoint(x: dot2.x - spacing, y: y)
    let dash3p1 = CGPoint(x: dot2.x + spacing, y: y)

    roundedLine(p0: dash1p1, p1: dash1p2, colour: W3WSettings.color(named: "DashesColor"), lineWidth: size)
    roundedLine(p0: dot1, p1: dot1, colour: W3WSettings.color(named: "DashesColor"), lineWidth: size)
    roundedLine(p0: dash2p1, p1: dash2p2, colour: W3WSettings.color(named: "DashesColor"), lineWidth: size)
    roundedLine(p0: dot2, p1: dot2, colour: W3WSettings.color(named: "DashesColor"), lineWidth: size)
    roundedLine(p0: dash3p1, p1: dash3p2, colour: W3WSettings.color(named: "DashesColor"), lineWidth: size)

    //roundedLine(p0: CGPoint(x: size * 2.0, y: rect.height / 2.0), p1: CGPoint(x: rect.width - size * 4.0, y: rect.height / 2.0), colour: dashColour, lineWidth: size)
  }
  
  
}

#endif
