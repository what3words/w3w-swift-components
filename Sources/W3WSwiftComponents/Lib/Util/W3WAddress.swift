//
//  File.swift
//  
//
//  Created by Dave Duprey on 10/05/2021.
//

import Foundation


class W3WAddress {
  
  static func equal(w1: String, w2: String) -> Bool {
    return W3WAddress.removeLeadingSlashes(w1).lowercased() == W3WAddress.removeLeadingSlashes(w2).lowercased()
  }
  
  
  static func removeLeadingSlashes(_ w: String) -> String {
    var x = w;
    while x.prefix(1) == "/" {
      _ = x.removeFirst()
    }
    
    return x;
  }
  
  
  static func ensureLeadingSlashes(_ w: String) -> String {
    return "///" + W3WAddress.removeLeadingSlashes(w)
  }
  
}
