//
//  File.swift
//  
//
//  Created by Dave Duprey on 17/11/2020.
//

import Foundation
import W3WSwiftApi


public typealias W3WSuggestionResponse = (W3WSuggestion) -> ()
public typealias W3WTextChangedResponse = (String?) -> ()
public typealias W3WAutoSuggestTextFieldErrorResponse = (W3WAutosuggestComponentError) -> ()

/// interface for text field type components
public protocol W3WAutoSuggestTextFieldProtocol: class, W3WOptionAcceptorProtocol {
  var suggestionSelected: W3WSuggestionResponse { get set }
  var textChanged: W3WTextChangedResponse { get set }
  var onError: W3WAutoSuggestTextFieldErrorResponse { get set }
  func set(_ w3w: W3WProtocolV3, language: String)
  func set(freeformText: Bool)
  func set(allowInvalid3wa: Bool)
  func set(language l: String)
  func set(voice: Bool)
  
  /// NOTE: this causes the component to use the converToCoordinates call, which may count against your quota
  func set(includeCoordinates: Bool)
}



