//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//
#if !os(macOS) && !os(watchOS)

import UIKit
import W3WSwiftCore


@IBDesignable
public class W3WCloseIconView: W3WDrawingView {
  
  // MARK: Drawing
    
  /// draw the microphone
  public override func make(_ rect: CGRect) {
    let lineWidth = rect.maxX * 0.1
    roundedLine(p0: CGPoint(x: lineWidth, y: lineWidth), p1: CGPoint(x: rect.maxX - lineWidth, y: rect.maxX - lineWidth), colour: W3WSettings.color(named: "CloseIconColor"), lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: rect.maxX - lineWidth, y: lineWidth), p1: CGPoint(x: lineWidth, y: rect.maxY - lineWidth), colour: W3WSettings.color(named: "CloseIconColor"), lineWidth: lineWidth)
  }
  
  
}


#endif
