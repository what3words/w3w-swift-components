//
//  File.swift
//  
//
//  Created by Dave Duprey on 10/05/2021.
//

import Foundation


/// continass functions for formatting three word addresses and comparing them
class W3WAddress {
  
  /// check three word address string equality, ignoring ///
  static func equal(w1: String, w2: String) -> Bool {
    return W3WAddress.removeLeadingSlashes(w1).lowercased() == W3WAddress.removeLeadingSlashes(w2).lowercased()
  }
  
  
  /// remove /// from three word addresses
  static func removeLeadingSlashes(_ w: String) -> String {
    var x = w;
    while x.prefix(1) == "/" {
      _ = x.removeFirst()
    }
    
    return x;
  }
  
  
  /// make sure a three word address starts with a ///
  static func ensureLeadingSlashes(_ w: String) -> String {
    return "///" + W3WAddress.removeLeadingSlashes(w)
  }
  
}
