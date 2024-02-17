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
public class W3WMapPin: W3WDrawingView {
  
  
  @IBInspectable var slashColour = W3WSettings.color(named: "SlashesColor")    //: UIColor   = UIColor(red: 0.810, green: 0.217, blue: 0.196, alpha: 1.0)
  
  var text: String?
  var style: W3WMarkerStyle = .pin
  var colour: UIColor?

  public init(frame: CGRect, text: String?, style: W3WMarkerStyle = .pin, color: UIColor? = nil) {
    super.init(frame: frame)
    self.text = text
    self.style = style
    self.colour = color
    instantiateUIElements()
  }

  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  
  public func getOffset() -> CGPoint {
    if style == .pin {
      return CGPoint(x: 0.0, y: -W3WSettings.pinSize / 2.0)
    } else {
      return CGPoint(x: 0.0, y: 0.0)
    }
  }
  
  
  func marker(rect: CGRect) {
    if style == .pin {
      pin(rect: rect)
    } else {
      circle(rect: rect)
    }
  }
  
  
  func circle(rect: CGRect) {
    let theColour     = colour ?? W3WSettings.color(named: "MapCircleColor")
    let tintColour:UIColor = W3WColorScheme.isLight(colour: theColour) ? .black : .white

    let radius        = rect.size.width / 2.0
    let centre        = CGPoint(x:rect.midX, y:rect.midY)
    let slashpadding  = radius * 0.68
    let lineWidth     = slashpadding * 0.18
    
    circle(centre: centre, radius: radius, colour: tintColour)
    circle(centre: centre, radius: radius - lineWidth, colour: theColour)

    let slashrect = rect.inset(by: UIEdgeInsets(top: slashpadding, left: slashpadding, bottom: slashpadding, right: slashpadding))
    slashes(rect: slashrect, colour: tintColour, width: lineWidth)
  }
  
  
  func pin(rect: CGRect) {
    let theColour = colour ?? W3WSettings.color(named: "MapPinColor")
    let tintColour:UIColor = W3WColorScheme.isLight(colour: theColour) ? .black : .white

    let centre        = CGPoint(x:rect.midX, y:rect.maxY - W3WSettings.pinOffset)
    let size          = W3WSettings.pinSize
    let slashpadding  = size * 0.3
    let lineWidth     = slashpadding * 0.18
    let r             = CGRect(x: centre.x - size / 2.0, y: center.y - size / 2.0 - W3WSettings.pinOffset, width: size, height: size)

    rectangle(rect: r, colour: theColour)

    circle(centre: CGPoint(x: centre.x, y: center.y - size / 2.0 - W3WSettings.pinOffset + size), radius: W3WSettings.pinOffset, colour: theColour)

    roundedLine(p0: CGPoint(x: centre.x + W3WSettings.pinSize / 6.0, y: centre.y - W3WSettings.pinSize / 4.0), p1: centre, colour: theColour, lineWidth: W3WSettings.pinOffset)
    roundedLine(p0: CGPoint(x: centre.x - W3WSettings.pinSize / 6.0, y: centre.y - W3WSettings.pinSize / 4.0), p1: centre, colour: theColour, lineWidth: W3WSettings.pinOffset)

    
    let slashrect = r.inset(by: UIEdgeInsets(top: slashpadding, left: slashpadding, bottom: slashpadding, right: slashpadding))
    slashes(rect: slashrect, colour: tintColour, width: lineWidth)
  }
  
  
  // MARK: Drawing

  
  /// draw the microphone
  public override func make(_ rect: CGRect) {
    marker(rect: rect)
  }
  
  
}


#endif
