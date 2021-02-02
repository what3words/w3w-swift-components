//
//  W3WAddress.swift
//  
//
//  Created by Dave Duprey on 29/09/2020.
//

import Foundation
import UIKit
import W3WSwiftApi


/// class for formatting w3w addresses as NSAttributedString
class W3WAddress {
  
  var address: String?
  
  init(_ address:String?) {
    self.address = address
  }
  
  
  func withSlashes(fontSize:CGFloat, slashColor: UIColor? = nil) -> NSAttributedString? {
    return withSlashes(font: pickaFont(size: fontSize), slashColor: slashColor)
  }
  
  
  func withSlashes(font:UIFont? = nil, slashColor:UIColor? = nil) -> NSAttributedString? {
    let slashAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: slashColor ?? W3WSettings.componentsSlashesColor,
      //.font: font ?? pickaFont()
    ]
    
    let slashes = NSMutableAttributedString(string: "///", attributes: slashAttributes)
    let formattedAddress = NSMutableAttributedString(string: address ?? "")
    
    slashes.append(formattedAddress)
    return slashes
  }
  
  
  func pickaFont(size: CGFloat? = nil) -> UIFont {
    var font: UIFont

    if let s = size {
      if let f = UIFont(name: "SourceSansPro-Regular", size: s) {
        font = f
      } else {
        font = UIFont.systemFont(ofSize: s)
      }
    } else {
      font = UIFont.preferredFont(forTextStyle: .body)
    }

    return font
  }
  
  
  public static func ensureSlashes(text: NSAttributedString?) -> NSAttributedString? {
    let plainString = text?.string
    return W3WAddress.ensureSlashes(text: plainString)
  }
  
  
  public static func ensureSlashes(text: String?, font: UIFont? = nil) -> NSAttributedString? {
    let plainAddress = text?.replacingOccurrences(of: "/", with: "")
    let address = W3WAddress(plainAddress)
    return address.withSlashes(font: font)
  }

  
}
