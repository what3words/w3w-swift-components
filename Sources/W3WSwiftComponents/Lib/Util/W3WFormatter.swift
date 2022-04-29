//
//  W3WFormatter.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//
#if !os(macOS)

import Foundation
import UIKit
import MapKit
import W3WSwiftApi


enum W3WFontWeight {
  case regular
  case semibold
}


/// class for formatting w3w addresses as NSAttributedString
class W3WFormatter {
  
  var address: String?
  
  init(_ address:String?) {
    self.address = address
  }
  
  
  func withSlashes(fontSize:CGFloat, slashColor: UIColor? = nil, weight: W3WFontWeight = .regular) -> NSAttributedString? {
    return withSlashes(font: W3WFormatter.pickaFont(size: fontSize, weight: weight), slashColor: slashColor)
  }
  
  
  func withSlashes(font:UIFont? = nil, slashColor:UIColor? = nil, weight: W3WFontWeight = .regular) -> NSAttributedString? {
    let slashAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: slashColor ?? W3WSettings.color(named: "SlashesColor"),
      .font: font ?? W3WFormatter.pickaFont(size: font?.pointSize, weight: weight)
    ]

    let fontAttributes: [NSAttributedString.Key: Any] = [
      .font: font ?? W3WFormatter.pickaFont(size: font?.pointSize, weight: weight)
    ]

    let slashes = NSMutableAttributedString(string: "///", attributes: slashAttributes)
    let formattedAddress = NSMutableAttributedString(string: address ?? "", attributes: fontAttributes)
    
    slashes.append(formattedAddress)
    return slashes
  }
  
  
  static func pickaFont(size: CGFloat? = nil, weight: W3WFontWeight) -> UIFont {
    var font: UIFont

    if let s = size {
      if let f = UIFont(name: "SourceSansPro-Regular", size: s) {
        font = f
      } else {
        if weight == .semibold {
          font = UIFont.systemFont(ofSize: s, weight: .semibold)
        } else {
          font = UIFont.systemFont(ofSize: s, weight: .regular)
        }
      }
    } else {
      if weight == .semibold {
        #if os(watchOS)
        font = UIFont.systemFont(ofSize: W3WSettings.systemFontSizeForWatchOS, weight: .semibold)
        #else
        font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        #endif
      } else {
        #if os(watchOS)
        font = UIFont.systemFont(ofSize: W3WSettings.systemFontSizeForWatchOS, weight: .regular)
        #else
        font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        #endif
      }
    }

    return font
  }
  
  
  public static func ensureSlashes(text: NSAttributedString?) -> NSAttributedString? {
    let plainString = text?.string
    return W3WFormatter.ensureSlashes(text: plainString)
  }
  
  
  public static func ensureSlashes(text: String?, font: UIFont? = nil) -> NSAttributedString? {
    let plainAddress = text?.replacingOccurrences(of: "/", with: "")
    let address = W3WFormatter(plainAddress)
    return address.withSlashes(font: font)
  }

  
  public static func distanceAsString(meters: Double) -> String {
    var distance = ""
    
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = .abbreviated
    
    // note: W3WSettings.measurement might be .userPreference, in which case formatter.units is let to it's default
    if W3WSettings.measurement == .metric {
      formatter.units = .metric
    } else if W3WSettings.measurement == .imperial {
      formatter.units = .imperial
    }
    
    distance = formatter.string(fromDistance: meters)
    
    return distance
  }

  
  public static func distanceAsString(kilometers: Double) -> String {
    var distance = ""
    
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = .abbreviated
    
    // note: W3WSettings.measurement might be .userPreference, in which case formatter.units is let to it's default
    if W3WSettings.measurement == .metric {
      formatter.units = .metric
    } else if W3WSettings.measurement == .imperial {
      formatter.units = .imperial
    }
    
    if kilometers == 0 {
      distance = "<" + formatter.string(fromDistance: 1000.0)
    } else {
      distance = formatter.string(fromDistance: kilometers * 1000.0)
    }
    //distance = formatter.string(fromDistance: 2.0)
    
    distance = distance.replacingOccurrences(of: ".0", with: "")
    
    return distance
  }

}


#endif
