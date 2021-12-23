//
//  File.swift
//  
//
//  Created by Dave Duprey on 07/10/2021.
//

import Foundation
import W3WSwiftApi


/// error response code block definition
public typealias W3WMapErrorResponse = (W3WMapError) -> ()


/// errors the map components might face
public enum W3WMapError : Error, CustomStringConvertible {
  case mapNotConfigured
  case apiError(error: W3WError)
  
  public var description : String {
    switch self {
    case .mapNotConfigured:     return "Map isn't configured properly, is the API or SDK set?"
    case .apiError(let error):  return String(describing: error)
    }
  }
  
}


