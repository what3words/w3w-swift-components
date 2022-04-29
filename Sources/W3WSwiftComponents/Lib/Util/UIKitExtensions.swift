//
//  ViewController.swift
//  Simple Coordinator
//
//  Created by Lshiva on 17/05/2020.
//  Copyright © 2020 what3words. All rights reserved.
//
#if !os(macOS)


import Foundation
import UIKit


// MARK: UIView


#if !os(watchOS)
extension UIView {
  var w3wParentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}
#endif

// MARK: UIColor

extension UIColor {

  // allow instantiation of a UIColor from a html/css type hex string
  convenience init(w3whex: String) {
    let hex = w3whex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (0, 0, 0, 1)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }

  
  // allow instantiation of a UIColor from a hexadecimal number and optional alpha value
  convenience init(w3whex: Int, alpha: CGFloat = 1.0) {
    let red   = CGFloat((w3whex >> 16) & 0xFF)
    let green = CGFloat((w3whex >> 8) & 0xFF)
    let blue  = CGFloat(w3whex & 0xFF)

    self.init(
      red: red / 255.0,
      green: green / 255.0,
      blue: blue / 255.0,
      alpha: alpha
    )
  }
  
}


// MARK: NSAttributedString


public extension NSAttributedString {

  /// construct a formatted string with coloured leading slashes
  convenience init(threeWordAddress: String, font: UIFont? = nil) {
    if let atributedString = W3WFormatter.ensureSlashes(text: threeWordAddress, font: font) {
      self.init(attributedString: atributedString)
    } else {
      self.init(string: threeWordAddress)
    }
  }
  
}


#endif
