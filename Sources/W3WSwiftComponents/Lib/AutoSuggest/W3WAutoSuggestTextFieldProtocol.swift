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
public protocol W3WAutoSuggestTextFieldProtocol: AnyObject, W3WOptionAcceptorProtocol {
<<<<<<< HEAD
  var suggestionSelected: W3WSuggestionResponse { get set }
=======
  var onSuggestionSelected: W3WSuggestionResponse { get set }
  var suggestionSelected: W3WSuggestionResponse { get set }  /// DEPRECIATED: use onSuggestionSelected instead - old callback for when the user choses a suggestion, to be depreciate
>>>>>>> 43a11ffcb92ed6131dad6b872343efea08bb7986
  var textChanged: W3WTextChangedResponse { get set }
  var onError: W3WAutoSuggestTextFieldErrorResponse { get set }
  func set(_ w3w: W3WProtocolV3, language: String)
  func set(freeformText: Bool)
  func set(allowInvalid3wa: Bool)
  func set(language l: String)
  func set(voice: Bool)
  func set(display: W3WSuggestion?)
  
  /// NOTE: this causes the component to use the converToCoordinates call, which may count against your quota
  func set(includeCoordinates: Bool)
}

