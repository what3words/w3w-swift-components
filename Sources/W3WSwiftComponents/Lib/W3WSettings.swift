//
//  File.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//

import W3WSwiftApi
import UIKit


public enum W3WMesurementSystem {
  case metric
  case imperial
  case system
}


public enum W3WColourMode {
  case light
  case dark
}


public extension W3WSettings {

  static let W3WSwiftComponentsVersion = "2.1.0"
  
  // mutable settings
  static var measurement = W3WMesurementSystem.system
  static var leftToRight = (NSLocale.characterDirection(forLanguage: NSLocale.preferredLanguages.first ?? "en") == Locale.LanguageDirection.leftToRight)
  
  // will be used for dark mode - not quite ready yet
  static let colourMode = W3WColourMode.light
  //static var colourMode: W3WColourMode {
  //  if #available(iOS 12, *) {
  //     return UIScreen.main.traitCollection.userInterfaceStyle == .light ? W3WColourMode.light : W3WColourMode.dark
  //  } else {
  //    return W3WColourMode.light
  //  }
  //}
  
  // colours
  static let componentsSlashesColor         = UIColor(hex: 0xE11F26)
  static let componentsDashesColor          = UIColor(hex: 0xD9D9D9)
  static let componentsSeparatorColor       = UIColor(hex: 0xE5E5E5)
  static let componentsCheckMarkColor       = UIColor(hex: 0x5FC98F)
  static let componentsErrorTintColor       = UIColor(hex: 0xED694E)
  static let componentsWarningTintColor     = UIColor(hex: 0x0A3049)
  static let componentsBorderColor          = UIColor(hex: 0xC2C2C2)
  static let componentsMicBackground        = UIColor(red: 0.975, green: 0.975, blue: 0.975, alpha: 1.0)
  static let componentsMicTextColor         = UIColor.black
  static let componentsMicTextSecondary     = UIColor.gray
  static let componentsMicShadow            = UIColor.darkGray
  static let componentsCloseIconColor       = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

  // dark/light mode dependant colours
  static var componentsNearestPlaceColor:   UIColor { return colourMode == .light ? UIColor(hex: 0x525252) : UIColor.white }
  static var componentsAddressTextColor:    UIColor { return colourMode == .light ? UIColor(hex: 0x0A3049) : UIColor.white }
  static var componentsHighlightBacking:    UIColor { return colourMode == .light ? UIColor(hex: 0xDBEFFA) : UIColor.gray }
  static var componentsTableCellBacking:    UIColor { return colourMode == .light ? UIColor.white : UIColor.black }
  static var componentsTextfieldBackground: UIColor { return colourMode == .light ? UIColor.white : UIColor.black }
  static var componentsHintBackground:      UIColor { return colourMode == .light ? UIColor.white : UIColor.black }
  static var componentsErrorBackground:     UIColor { return colourMode == .light ? UIColor.white : UIColor.black }
  static var componentsMicOnColor:          UIColor { return colourMode == .light ? UIColor(red: 0.810, green: 0.217, blue: 0.196, alpha: 1.0) : .white }
  static var componentsMicOffColor:         UIColor { return colourMode == .light ? UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : .black }
  static var componentsVoiceIconColor:      UIColor { return colourMode == .light ? UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) : .white }

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
