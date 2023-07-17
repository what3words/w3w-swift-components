//
//  File.swift
//  
//
//  Created by Dave Duprey on 28/09/2020.
//
#if !os(macOS)

import Foundation
import UIKit

/// There is only the water flag.  All other country flags have been removed
public class W3WFlags {
  
  /// image of water
  // complicated implementation to allow for watchOS and iOS
  static var water: UIImage? {
    get {
      #if os(iOS)
      return UIImage(named: "flag.water", in: W3WBundle.module, compatibleWith: nil)
      #endif

      #if os(watchOS)
      if #available(watchOS 6.0, *) {
        return UIImage(named: "flag.water", in: W3WBundle.module, with: nil)
      } else {
        return UIImage()
      }
      #endif
    }
  }
  
  public init() { }
  
  static public func get(countryCode: String) -> UIImage? {

    if countryCode.uppercased() == "ZZ" {
      return W3WFlags.water
    }
    
    return nil
  }
  

}


#endif
