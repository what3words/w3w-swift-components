


//
//  MicrophoneView.swift
//  UberApiTest
//
//  Created by Dave Duprey on 07/02/2020.
//  Copyright © 2020 Dave Duprey. All rights reserved.
//

import UIKit


@IBDesignable
public class W3WCloseIconView: W3WDrawingView {
  
  
  @IBInspectable var colour: UIColor   = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

  
  // MARK: Drawing
    
  /// draw the microphone
  public override func make(_ rect: CGRect) {
    let lineWidth = rect.maxX * 0.1
    roundedLine(p0: CGPoint(x: lineWidth, y: lineWidth), p1: CGPoint(x: rect.maxX - lineWidth, y: rect.maxX - lineWidth), colour: colour, lineWidth: lineWidth)
    roundedLine(p0: CGPoint(x: rect.maxX - lineWidth, y: lineWidth), p1: CGPoint(x: lineWidth, y: rect.maxY - lineWidth), colour: colour, lineWidth: lineWidth)
  }
  
  
}

