//
//  File.swift
//  
//
//  Created by Dave Duprey on 19/07/2021.
//
#if !os(macOS)

import Foundation
import UIKit


/// possible colour modes
public enum W3WColourMode {
  case light
  case dark
}


/// a structure that holds all the colour information for an app
typealias W3WColorPalette = Dictionary<String, Dictionary<W3WColourMode, UIColor>>


/// contains a colourpalette for an app and hard coded w3w brand color values
public struct W3WColorScheme {
  
  /// default colour scheme
  var colors: W3WColorPalette = ["black" : [.light:.black, .dark:.white], "white" : [.light : .white, .dark:.white]]
  
  /// create a colour scheme using a colour palette
  init(colors: W3WColorPalette) {
    self.colors = colors
  }
  
  // named w3w brand colours
  static let w3wRed                 = UIColor(w3whex: 0xE11F26)
  static let w3wDarkBlue            = UIColor(w3whex: 0x0a3049)
  static let w3wWhite               = UIColor(w3whex: 0xffffff)
  static let w3wBlack               = UIColor(w3whex: 0x000000)
  static let w3wSecondaryCoral      = UIColor(w3whex: 0xf26c50)
  static let w3wSecondaryOrange     = UIColor(w3whex: 0xf4a344)
  static let w3wSecondaryGreen      = UIColor(w3whex: 0x53c18a)
  static let w3wSecondaryAqua       = UIColor(w3whex: 0x87e1d1)
  static let w3wSecondaryBlue       = UIColor(w3whex: 0x2e71b8)
  static let w3wSecondaryLightBlue  = UIColor(w3whex: 0x98d5e5)
  static let w3wSecondaryMustard    = UIColor(w3whex: 0xc5b000)
  static let w3wSecondaryYellow     = UIColor(w3whex: 0xf6d31f)
  static let w3wSupportLightGrey    = UIColor(w3whex: 0xe0e0e0)
  static let w3wSupportMediumGrey   = UIColor(w3whex: 0xa7a7a7)
  static let w3wSupportDarkGrey     = UIColor(w3whex: 0x363636)
  static let w3wUxRoyalBlue         = UIColor(w3whex: 0x005379)
  static let w3wUxCranberry         = UIColor(w3whex: 0xcd3b72)
  static let w3wUxPurple            = UIColor(w3whex: 0x8b4ca1)
  static let w3wUxPowderBlue        = UIColor(w3whex: 0xdbeffa)
  
  // named off brand colours
  static let componentOffWhite      = UIColor(w3whex: 0xF2F4F5)
  static let componentSubheading    = UIColor(w3whex: 0x525252)
  static let componentOffBlack      = UIColor(w3whex: 0x001626)
  
  // will be used for dark mode - not quite ready yet
  static var colourMode: W3WColourMode {
    if #available(iOS 12, *) {
       return UIScreen.main.traitCollection.userInterfaceStyle == .light ? W3WColourMode.light : W3WColourMode.dark
    } else {
      return W3WColourMode.light
    }
  }
 
  
  static public func isLight(colour: UIColor, threshold: Float = 0.5) -> Bool {
    let originalCGColor = colour.cgColor
    
    // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
    // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
    let rgbCgColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
    guard let components = rgbCgColor?.components else {
      return false
    }
    guard components.count >= 3 else {
      return false
    }
    
    let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
    return (brightness > threshold)
  }
  
}

#endif
