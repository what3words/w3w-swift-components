//
//  ObjcAutoSuggestComponentWrapper.swift
//
//  While this is implemented in Swift, it is compatible with Objective C and
//  designed to be used excusively with Objective C.  The thinking is that it
//  made more sense to provide a light ObjC wrapper than to infuse @obj directives
//  throughout the entire code base, and to adjust for peculiarities of NSObject
//  derived Swift classes.
//
//  Created by Dave Duprey on 24/03/2021.
//

import Foundation
import UIKit
import MapKit
import W3WSwiftApi



/// A text field for use with ObjectiveC, based on UITextField with a what3words autocomplete function
@objcMembers
public class W3WObjcAutoSuggestTextField: W3WAutoSuggestTextField {
  
  /// sets the voice recognitions feature on or off
  public func setVoice(_ voice: Bool) {
    set(voice: voice)
  }

  /// Allows any character to be typed in.  Defaults to `YES`.  If set to `NO` then all characters that are not part of a valid three word address will not be registered or displayed.
  public func setFreeformText(_ freeformText: Bool) {
    set(freeformText: freeformText)
  }
  
  /// This prevents the component from sending an error if the user leaves the field without entering a valid three word address.  Default is `NO`.
  public func setAllowInvalid3wa(_ allowInvalid3wa: Bool) {
    set(allowInvalid3wa: allowInvalid3wa)
  }
  
  /// Sets the expected input language
  public func setLanguage(_ l: String) {
    set(language: l)
  }
  
  
  /// Sets the options to use when calling autosuggest
  public func setOptions(_ options: W3WObjcOptions) {
    set(options: options.options)
  }
  
  
  /// Sets a closure that gets called when the user selects an address
  public func setSuggestionCallback(_ callback: @escaping (W3WObjcSuggestion) -> ()) {
    self.suggestionSelected = { suggestion in
      let s = W3WObjcSuggestion(suggestion: suggestion)
      callback(s)
    }
  }
  
  /// Sets a closure that gets called when the text in the textfield changes
  public func setTextChangedCallback(_ callback: @escaping (NSString) -> ()) {
    self.textChanged = { text in
      if let t = text {
        if let ns = NSString(utf8String: t) {
          callback(ns)
        }
      }
    }
  }
  
  /// Sets a closure that gets called when there is an error
  public func setErrorCallback(_ callback: @escaping (NSError) -> ()) {
    self.onError = { error in
      callback(NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description]))
    }
  }
  
}



/// A text field for use with ObjectiveC, based on UISearchController with a what3words autocomplete function
@objcMembers
public class W3WObjcAutoSuggestSearchController: W3WAutoSuggestSearchController {
  
  /// sets the voice recognitions feature on or off
  public func setVoice(_ voice: Bool) {
    set(voice: voice)
  }
  
  /// Allows any character to be typed in.  Defaults to `YES`.  If set to `NO` then all characters that are not part of a valid three word address will not be registered or displayed.
  public func setFreeformText(_ freeformText: Bool) {
    set(freeformText: freeformText)
  }
  
  /// This prevents the component from sending an error if the user leaves the field without entering a valid three word address.  Default is `NO`.
  public func setAllowInvalid3wa(_ allowInvalid3wa: Bool) {
    set(allowInvalid3wa: allowInvalid3wa)
  }
  
  /// Sets the expected input language
  public func setLanguage(_ l: String) {
    set(language: l)
  }
  
  /// Sets the options to use when calling autosuggest
  public func setOptions(_ options: W3WObjcOptions) {
    set(options: options.options)
  }

  /// Sets a closure that gets called when the user selects an address
  public func setSuggestionCallback(_ callback: @escaping (W3WObjcSuggestion) -> ()) {
    self.suggestionSelected = { suggestion in
      let s = W3WObjcSuggestion(suggestion: suggestion)
      callback(s)
    }
  }
  
  /// Sets a closure that gets called when the text in the textfield changes
  public func setTextChangedCallback(_ callback: @escaping (NSString) -> ()) {
    self.textChanged = { text in
      if let t = text {
        if let ns = NSString(utf8String: t) {
          callback(ns)
        }
      }
    }
  }
  
  /// Sets a closure that gets called when there is an error
  public func setErrorCallback(_ callback: @escaping (NSError) -> ()) {
    self.onError = { error in
      callback(NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description]))
    }
  }

}

