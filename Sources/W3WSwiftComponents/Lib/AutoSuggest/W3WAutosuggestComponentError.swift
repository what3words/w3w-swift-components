//
//  File.swift
//  
//
//  Created by Dave Duprey on 03/09/2020.
//

import Foundation
import W3WSwiftApi


/// errors the autosuggest components might face
public enum W3WAutosuggestComponentError : Error, CustomStringConvertible {
  case noLanguageChosen
  case noValidAdressFound
  case voiceApiError(error: W3WVoiceError)
  case apiError(error: W3WError)
  
  public var description : String {
    switch self {
      case .noLanguageChosen:         return "No language option was provided to voice autosuggest call"
      case .noValidAdressFound:       return "No valid what3words address found"
      case .voiceApiError(let error): return String(describing: error)
      case .apiError(let error):      return String(describing: error)
    }
  }

}

