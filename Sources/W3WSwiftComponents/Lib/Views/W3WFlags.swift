//
//  File.swift
//  
//
//  Created by Dave Duprey on 28/09/2020.
//

import Foundation
import UIKit

/// There is only the water flag.  All other country flags have been removed
public class W3WFlags {
  
  static let water = UIImage(named: "flag.water", in: Bundle.module, compatibleWith: nil)
  
  public init() { }
  
  static public func get(countryCode: String) -> UIImage? {

    if countryCode.uppercased() == "ZZ" {
      return W3WFlags.water
    }
    
    return nil
  }
  

}

