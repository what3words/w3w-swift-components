//
//  File.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//

import W3WSwiftApi
import UIKit


public extension W3WSettings {
  
  static var leftToRight = (NSLocale.characterDirection(forLanguage: NSLocale.preferredLanguages.first ?? "en") == Locale.LanguageDirection.leftToRight)
  
  static let componentsSlashesColor       = UIColor(hex: 0xE11F26)
  static let componentsSeparatorColor     = UIColor(hex: 0xE5E5E5)
  static let componentsCheckMarkColor     = UIColor(hex: 0x5FC98F)
  static let componentsErrorTintColor     = UIColor(hex: 0xED694E)
  static let componentsWarningTintColor   = UIColor(hex: 0x0A3049)
  static let componentsBorderColor        = UIColor(hex: 0xC2C2C2)
  static let componentsNearestPlaceColor  = UIColor(hex: 0x525252)
  static let componentsAddressTextColor   = UIColor(hex: 0x0A3049)

  static let componentsAddressTextSize    = CGFloat(18.0)
  static let componentsTableCellHeight    = CGFloat(64.0)
  static let componentsMaxTableHeight     = CGFloat(300.0)
  static let componentsTableTopMargin     = CGFloat(8.0)
  static let componentsSlashesIconSize    = CGFloat(100.0)
  static let componentsSlashesPadding     = CGFloat(10.0)
  static let componentsIconPadding        = CGFloat(10.0)

  static let componentsLogoSize           = CGFloat(64.0)
  
  static let componentsPlaceholderText    = NSLocalizedString("e.g. lock.spout.radar", comment: "e.g. lock.spout.radar")
  static let componentsNearFormatText     = NSLocalizedString("near %@", comment: "near %@")  // used to say NSLocalizedString("near %@", comment: "near %@"), but we need translations for this
  static let technicalErrorText           = NSLocalizedString("Something went wrong, try again later", comment: "There was some technical problem")
  static let apiErrorText                 = NSLocalizedString("No valid what3word address found", comment: "The API didn't have an answer for the given input")
  static let didYouMeanText               = NSLocalizedString("Did you mean?", comment: "Asks if the user mean to write a different addres that is presented below this text")
  
  static let regex_3wa_characters         = "^/*([^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]|[.｡。･・︒។։။۔።।]){0,}$"
  static let regex_3wa_separator          = "[.｡。･・︒។։။۔።।]"
  static let regex_3wa_mistaken_separator = "[.｡。･・︒។։။۔።। ,-_/+]{1,2}"
  //static let regex_3wa_word               = "[^0-9`~!@#$%^&*()+\\-_=\\]\\[{\\}\\\\|'<,.>?/\";:£§º©®\\s]{1,}"
  static let regex_3wa_word               = "\\w+"
  static let regex_match                  = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_separator + W3WSettings.regex_3wa_word + "$"
  static let regex_loose_match            = "^/*" + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + W3WSettings.regex_3wa_mistaken_separator + W3WSettings.regex_3wa_word + "$"

}
