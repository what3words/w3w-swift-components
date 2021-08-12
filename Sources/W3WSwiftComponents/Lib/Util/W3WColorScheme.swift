//
//  File.swift
//  
//
//  Created by Dave Duprey on 19/07/2021.
//

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
struct W3WColorScheme {
  
  /// default colour scheme
  var colors: W3WColorPalette = ["black" : [.light:.black, .dark:.white], "white" : [.light : .white, .dark:.white]]
  
  /// create a colour scheme using a colour palette
  init(colors: W3WColorPalette) {
    self.colors = colors
  }
  
  // named w3w brand colours
  static let w3wRed                 = UIColor(hex: 0xE11F26)
  static let w3wDarkBlue            = UIColor(hex: 0x0a3049)
  static let w3wWhite               = UIColor(hex: 0xffffff)
  static let w3wBlack               = UIColor(hex: 0x000000)
  static let w3wSecondaryCoral      = UIColor(hex: 0xf26c50)
  static let w3wSecondaryOrange     = UIColor(hex: 0xf4a344)
  static let w3wSecondaryGreen      = UIColor(hex: 0x53c18a)
  static let w3wSecondaryAqua       = UIColor(hex: 0x87e1d1)
  static let w3wSecondaryBlue       = UIColor(hex: 0x2e71b8)
  static let w3wSecondaryLightBlue  = UIColor(hex: 0x98d5e5)
  static let w3wSecondaryMustard    = UIColor(hex: 0xc5b000)
  static let w3wSecondaryYellow     = UIColor(hex: 0xf6d31f)
  static let w3wSupportLightGrey    = UIColor(hex: 0xe0e0e0)
  static let w3wSupportMediumGrey   = UIColor(hex: 0xa7a7a7)
  static let w3wSupportDarkGrey     = UIColor(hex: 0x363636)
  static let w3wUxRoyalBlue         = UIColor(hex: 0x005379)
  static let w3wUxCranberry         = UIColor(hex: 0xcd3b72)
  static let w3wUxPurple            = UIColor(hex: 0x8b4ca1)
  static let w3wUxPowderBlue        = UIColor(hex: 0xdbeffa)
  
  // named off brand colours
  static let componentOffWhite      = UIColor(hex: 0xF2F4F5)
  static let componentSubheading    = UIColor(hex: 0x525252)
  static let componentOffBlack      = UIColor(hex: 0x001626)
  
  // will be used for dark mode - not quite ready yet
  static var colourMode: W3WColourMode {
    if #available(iOS 12, *) {
       return UIScreen.main.traitCollection.userInterfaceStyle == .light ? W3WColourMode.light : W3WColourMode.dark
    } else {
      return W3WColourMode.light
    }
  }
  
}
