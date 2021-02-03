


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
public class W3WSlashesView: W3WDrawingView {
  
  public var alignment = W3WHorizontalAlignment.center
  
  @IBInspectable var slashColour = W3WSettings.componentsSlashesColor    //: UIColor   = UIColor(red: 0.810, green: 0.217, blue: 0.196, alpha: 1.0)
  
  // MARK: Drawing
    
  /// draw the microphone
  public override func make(_ rect: CGRect) {

    var alignedRect = rect

    if alignment == .leading {
      alignedRect = CGRect(x: 0.0, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    } else if alignment == .trailing {
      alignedRect = CGRect(x: rect.size.width - rect.size.height, y: rect.origin.y, width: rect.size.height, height: rect.size.height)
    }

    slashes(rect: alignedRect, colour: slashColour)
  }
  
  
}

