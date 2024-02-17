//
//  File.swift
//  
//
//  Created by Dave Duprey on 03/09/2020.
//

import Foundation
import W3WSwiftCore


public extension W3WError {
  
  static let noLanguageChosen   = W3WError.message("No language option was provided to voice autosuggest call")
  static let noValidAdressFound = W3WError.message("No valid what3words address found")
  static let superViewMissing   = W3WError.message("Autosuggest must be a subview of another view")
  //  case voiceApiError(error: W3WVoiceError)
  //  case apiError(error: W3WError)

}


/// errors the autosuggest components might face
//public enum W3WAutosuggestComponentError : Error, CustomStringConvertible {
//  case noLanguageChosen
//  case noValidAdressFound
//  case superViewMissing
//  case voiceApiError(error: W3WVoiceError)
//  case apiError(error: W3WError)
//  
//  public var description : String {
//    switch self {
//      case .noLanguageChosen:         return "No language option was provided to voice autosuggest call"
//      case .noValidAdressFound:       return "No valid what3words address found"
//      case .superViewMissing:         return "Autosuggest must be a subview of another view"
//      case .voiceApiError(let error): return String(describing: error)
//      case .apiError(let error):      return String(describing: error)
//    }
//  }
//
//}

