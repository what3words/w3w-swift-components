//
//  File.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//

import W3WSwiftApi
import UIKit


/// mertic imperial or default from the system
public enum W3WMesurementSystem {
  case metric
  case imperial
  case system
}


public extension W3WSettings {

  static let W3WSwiftComponentsVersion = "2.2.0"
  
  // mutable settings
  static var measurement = W3WMesurementSystem.system
  static var leftToRight = (NSLocale.characterDirection(forLanguage: NSLocale.preferredLanguages.first ?? "en") == Locale.LanguageDirection.leftToRight)
  
  // MARK:- Colours
  
  static internal var colorPalette:W3WColorPalette =
    [
      "SlashesColor"        : [.light: W3WColorScheme.w3wRed],
      "DashesColor"         : [.light: W3WColorScheme.w3wSupportLightGrey],
      "SeparatorColor"      : [.light: W3WColorScheme.w3wSupportLightGrey],
      "CheckMarkColor"      : [.light: W3WColorScheme.w3wSecondaryGreen],
      "ErrorTintColor"      : [.light: W3WColorScheme.w3wSecondaryCoral],
      "WarningTintColor"    : [.light: W3WColorScheme.w3wDarkBlue],
      "BorderColor"         : [.light: W3WColorScheme.w3wSupportMediumGrey],
      "MicTextSecondary"    : [.light: W3WColorScheme.w3wSupportMediumGrey],
      "MicShadow"           : [.light: W3WColorScheme.w3wSupportDarkGrey],
      "CloseIconColor"      : [.light: W3WColorScheme.w3wBlack],
      "MicTextColor"        : [.light: W3WColorScheme.w3wBlack],
      "MicBackground"       : [.light: W3WColorScheme.componentOffWhite],
      "NearestPlaceColor"   : [.light: W3WColorScheme.componentSubheading,    .dark: W3WColorScheme.w3wWhite],
      "AddressTextColor"    : [.light: W3WColorScheme.w3wDarkBlue,            .dark: W3WColorScheme.w3wWhite],
      "HighlightBacking"    : [.light: W3WColorScheme.w3wSecondaryLightBlue,  .dark: W3WColorScheme.w3wSupportMediumGrey],
      "TableCellBacking"    : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "TextfieldText"       : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wWhite],
      "TextfieldBackground" : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "TextfieldPlaceholder": [.light: W3WColorScheme.w3wSupportMediumGrey,   .dark: W3WColorScheme.w3wSupportMediumGrey],
      "HintBackground"      : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "ErrorBackground"     : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "MicOnColor"          : [.light: W3WColorScheme.w3wRed,                 .dark: W3WColorScheme.w3wWhite],
      "MicOffColor"         : [.light: W3WColorScheme.w3wWhite,               .dark: W3WColorScheme.w3wBlack],
      "VoiceIconColor"      : [.light: W3WColorScheme.w3wBlack,               .dark: W3WColorScheme.w3wWhite]
    ]

  /// the colour information for all components
  static internal var colors = W3WColorScheme(colors: colorPalette)
  
  /// set a colour for a colour mode
  static func set(color: UIColor, named: String, forMode: W3WColourMode) {
    colorPalette[named]?[forMode] = color
  }
  
  /// return a color of a particular name, in the current colour mode (dark/light), failing that return in any colour mode, failing that, return black
  static func color(named: String) -> UIColor {
    if let color = color(named: named, forMode: W3WColorScheme.colourMode) {
      return color
    } else {
      return colorPalette[named]?.first?.value ?? W3WColorScheme.w3wBlack
    }
  }

  /// return a color of a particular name, for a specific colour mode
  static func color(named: String, forMode: W3WColourMode) -> UIColor? {
    return colorPalette[named]?[forMode]
  }
  
  
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
  
  // display text
  static let componentsPlaceholderText    = NSLocalizedString("input_hint",               bundle: Bundle.module, comment: "e.g. ///lock.spout.radar")
  static let componentsNearFormatText     = NSLocalizedString("near",                     bundle: Bundle.module, comment: "near %@")  // used to say NSLocalizedString("near %@", comment: "near %@"), but we need translations for this
  static let technicalErrorText           = NSLocalizedString("error_message", 	          bundle: Bundle.module, comment: "There was some technical problem")
  static let apiErrorText                 = NSLocalizedString("invalid_address_message",  bundle: Bundle.module, comment: "The API didn't have an answer for the given input")
  static let didYouMeanText               = NSLocalizedString("correction_message",       bundle: Bundle.module, comment: "Asks if the user meant to write a different addres that is presented below this text")
  
  // regex
  static let regex_3wa_characters         = "^/*([^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]|[.｡。･・︒។։။۔።।]){0,}$"
  static let regex_3wa_separator          = "[.｡。･・︒។։။۔።।]"
  static let regex_3wa_mistaken_separator = "[.｡。･・︒។։။۔።। ,\\-_/+'&\\:;|]{1,2}"
  static let regex_3wa_word               = "\\w+"
  static let regex_match                  = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + "$"
  static let regex_loose_match            = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + "$"

}
