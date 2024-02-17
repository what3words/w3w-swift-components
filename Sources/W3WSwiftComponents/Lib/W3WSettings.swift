//
//  File.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//

import Foundation
import W3WSwiftCore

#if !os(macOS)
import UIKit
#endif

/// mertic imperial or default from the system
public enum W3WMesurementSystem {
  case metric
  case imperial
  case system
}


public extension W3WSettings {

  static let W3WSwiftComponentsVersion = "2.4.0"
  
  // mutable settings
  static var measurement = W3WMesurementSystem.system
  static var leftToRight = (NSLocale.characterDirection(forLanguage: NSLocale.preferredLanguages.first ?? W3WSettings.defaultLanguage.code) == Locale.LanguageDirection.leftToRight)
  
  // MARK: Colours

  #if !os(macOS)

  static internal var colorPalette:W3WColorPalette =
    [
      "SlashesColor"        : [.light: W3WColorScheme.w3wRed],
      "DashesColor"         : [.light: W3WColorScheme.w3wSupportLightGrey],
      "CheckMarkColor"      : [.light: W3WColorScheme.w3wSecondaryGreen],
      "ErrorTextColor"      : [.light: W3WColorScheme.w3wRed,                 .dark: W3WColorScheme.w3wDarkBlue],
      "ErrorBackground"     : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wSecondaryCoral],
      "WarningTextColor"    : [.light: W3WColorScheme.w3wRed,                 .dark: W3WColorScheme.w3wDarkBlue],
      "WarningBackground"   : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wSecondaryCoral],
      "BorderColor"         : [.light: W3WColorScheme.w3wSupportMediumGrey,   .dark: W3WColorScheme.w3wBlack],
      "SeparatorColor"      : [.light: W3WColorScheme.w3wSupportLightGrey,    .dark: W3WColorScheme.w3wSupportMediumGrey],
      "MicTextSecondary"    : [.light: W3WColorScheme.w3wSupportMediumGrey],
      "MicShadow"           : [.light: W3WColorScheme.w3wSupportDarkGrey],
      "CloseIconColor"      : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wSupportMediumGrey],
      "MicTextColor"        : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wWhite],
      "MicBackground"       : [.light: W3WColorScheme.componentOffWhite,      .dark: W3WColorScheme.w3wDarkBlue],
      "NearestPlaceColor"   : [.light: W3WColorScheme.componentSubheading,    .dark: W3WColorScheme.w3wSupportLightGrey],
      "AddressTextColor"    : [.light: W3WColorScheme.w3wDarkBlue,            .dark: W3WColorScheme.w3wWhite],
      "HighlightBacking"    : [.light: W3WColorScheme.w3wSecondaryLightBlue,  .dark: W3WColorScheme.w3wDarkBlue],
      "TableCellBacking"    : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "TextfieldText"       : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wWhite],
      "TextfieldBackground" : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.componentOffBlack],
      "TextfieldPlaceholder": [.light: W3WColorScheme.w3wSupportMediumGrey,   .dark: W3WColorScheme.w3wSupportMediumGrey],
      "HintBackground"      : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.componentOffBlack],
      "HintTextColor"       : [.light: W3WColorScheme.w3wDarkBlue,            .dark: W3WColorScheme.w3wWhite],
      "HintTopLine"         : [.light: W3WColorScheme.w3wDarkBlue,            .dark: .clear],
      "MicOnColor"          : [.light: W3WColorScheme.w3wRed,                 .dark: W3WColorScheme.w3wRed],
      "MicOffColor"         : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wDarkBlue],
      "VoiceIconColor"      : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wWhite],
      
      "MapGridColor"        : [.light: W3WColorScheme.w3wSupportMediumGrey,   .dark: W3WColorScheme.w3wSupportMediumGrey],
      "MapSquareColor"      : [.light: W3WColorScheme.w3wDarkBlue,            .dark: W3WColorScheme.w3wSupportLightGrey],
      "MapPinColor"         : [.light: W3WColorScheme.w3wDarkBlue,            .dark: W3WColorScheme.w3wRed],
      "MapCircleColor"      : [.light: W3WColorScheme.w3wRed,                 .dark: W3WColorScheme.w3wRed]
    ]

  
  /// the colour information for all components
  static internal var colors = W3WColorScheme(colors: colorPalette)
  
  
  /// set a colour for a colour mode
  static func set(color: UIColor, named: String, forMode: W3WColourMode) {
    colorPalette[named]?[forMode] = color
  }
  
  
  /// return a color of a particular name, in the current colour mode (dark/light), failing that return in any colour mode, failing that, return black
  static func color(named: String) -> UIColor {
    return color(named: named, forMode: W3WColorScheme.colourMode)
  }

  
  /// return a color of a particular name, for a specific colour mode, if no such colour exists, return the light mode colour, failing that, return any colour for that name, failing that, return black
  static func color(named: String, forMode: W3WColourMode) -> UIColor {
    if let color = colorPalette[named]?[forMode] {
      return color
    } else {
      return (colorPalette[named]?[.light] ?? colorPalette[named]?.first?.value) ?? W3WColorScheme.w3wBlack
    }
  }
  
  #endif
  
  // MARK: Text
  
  // text sizes
  static let componentsAddressTextSize    = CGFloat(18.0)
  static let componentsTableCellHeight    = CGFloat(64.0)
  static let componentsMaxTableHeight     = CGFloat(300.0)
  static let componentsTableTopMargin     = CGFloat(8.0)
  static let componentsSlashesIconSize    = CGFloat(100.0)
  static let componentsSlashesPadding     = CGFloat(10.0)
  static let componentsIconPadding        = CGFloat(10.0)
  static let componentsLogoSize           = CGFloat(64.0)
  static let componentsTextFieldWidth     = CGFloat(300.0)
  static let componentsTextFieldHeight    = CGFloat(48.0)
  static let systemFontSizeForWatchOS     = CGFloat(12.0)

  // display text
  static let componentsPlaceholderText    = diviseTranslation(tag: "input_hint",              backup: "e.g. ///index.home.raft")
  static let componentsNearFormatText     = diviseTranslation(tag: "near",                    backup: "near ${PARAM}")
  static let technicalErrorText           = diviseTranslation(tag: "error_message",           backup: "An error occurred. Please try later.")
  static let apiErrorText                 = diviseTranslation(tag: "invalid_address_message", backup: "No valid what3words address found")
  static let didYouMeanText               = diviseTranslation(tag: "correction_message",      backup: "Did you mean?")

  static func diviseTranslation(tag: String, backup: String) -> String {
    var translation = NSLocalizedString(tag, bundle: W3WBundle.module, comment: backup)
    
    // near is a special case, if a translation is not available then we drop 'near' and just return the value, usually 'nearestPlace'
    if translation == "near" {
      translation = "${PARAM}"
      
    // if the translation is missing then use the default
    } else if translation == tag {
      translation = backup
    }
    
    return translation.replacingOccurrences(of: "${PARAM}", with: "%@")
  }
  
  
  // MARK: Geometry

  static var uiIndent             = CGFloat(8.0)
  static let pinSize   = CGFloat(40.0)
  static let pinOffset = CGFloat(5.0)
  static let mapSquareLineThickness = CGFloat(2.0)
  static let mapGridLineThickness    = CGFloat(0.5)
  
  
  // MARK: Geography
  
  static let mapDefaultZoomPointsPerSquare          = CGFloat(32.0)
  static let mapGridInvisibleAtPointsPerSquare      = CGFloat(11.0)
  static let mapGridOpaqueAtPointsPerSquare         = CGFloat(11.001)
  static let mapAnnotationTransitionPointsPerSquare = CGFloat(12.0)
  

  
}
