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


/// Objective-C compatible Suggestion object
@objcMembers public class W3WObjcSuggestion: NSObject {
  public var words: NSString?
  public var country: NSString?
  public var nearestPlace: NSString?
  public var distanceToFocus: NSNumber?
  public var language: NSString?
  
  public init(words: String?, country: String?, nearestPlace: String?, distanceToFocus: NSNumber?, language: String?) {
    self.words            = words as NSString?
    self.country          = country as NSString?
    self.nearestPlace     = nearestPlace as NSString?
    self.distanceToFocus  = NSNumber(nonretainedObject: distanceToFocus)
    self.language         = language as NSString?
  }
}


/// ObjC enum for autosuggest input type option
@objc public enum W3WObjcInputType: Int {
  case text
  case voconHybrid
  case nmdpAsr
  case genericVoice
  case speechmatics
  case mihup
}


/// ObjC compatible option object for autosuggest calls
@objcMembers public class W3WObjcOptions: NSObject {
  var options = [W3WOption]()
  
  /// location of the user to help autosuggest provide more relevant suggestions
  public func addFocus(_ focus: CLLocationCoordinate2D) {
    options.append(W3WOption.focus(focus))
  }
  
  /// language to use for the voice API
  public func addVoiceLanguage(_ voiceLanguage: String) {
    options.append(W3WOption.voiceLanguage(voiceLanguage))
  }
  
  /// number of results that will use the focus option
  public func addNumberFocusResults(_ numberFocusResults: Int) {
    options.append(W3WOption.numberFocusResults(numberFocusResults))
  }

  /// the number of results to return in total
  public func addNumberOfResults(_ numberOfResults: Int) {
    options.append(W3WOption.numberOfResults(numberOfResults))
  }

  /// tells autosuggest to only return results from one country
  public func addClipToCountry(_ clipToCountry: String) {
    options.append(W3WOption.clipToCountry(clipToCountry))
  }

  /// tells autosuggest to limit results to particular countries
  public func addClipToCountries(_ clipToCountries: [String]) {
    options.append(W3WOption.clipToCountries(clipToCountries))
  }

  /// limit results to a particular geographic circle
  public func addClipToCircle(_ center:CLLocationCoordinate2D, radius: Double) {
    options.append(W3WOption.clipToCircle(center: center, radius: radius))
  }

  /// limit results to a geographic rectangle
  public func addClipToBoxSouthWest(_ southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D) {
    options.append(W3WOption.clipToBox(southWest: southWest, northEast: northEast))
  }

  /// limit results to a geographic polygon
  public func addClipToPolygon(_ clipToPolygon: [CLLocationCoordinate2D]) {
    options.append(W3WOption.clipToPolygon(clipToPolygon))
  }

  /// gives preference to land based addresses
  public func addPreferLand(_ preferLand: Bool) {
    options.append(W3WOption.preferLand(preferLand))
  }
  
  
  /// tells autosuggest which type of data is being passed to it (not relevant for autosuggest component)
  public func addInputType(_ inputType: W3WObjcInputType) {
    var it: W3WOption?

    switch inputType {
    case .genericVoice:
      it = W3WOption.inputType(.genericVoice)
    case .mihup:
      it = W3WOption.inputType(.mihup)
    case .nmdpAsr:
      it = W3WOption.inputType(.nmdpAsr)
    case .speechmatics:
      it = W3WOption.inputType(.speechmatics)
    case .text:
      it = W3WOption.inputType(.text)
    case .voconHybrid:
      it = W3WOption.inputType(.voconHybrid)
    }

    if let i = it {
      options.append(i)
    }
  }
}


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
      let s = W3WObjcSuggestion(words: suggestion.words, country: suggestion.country, nearestPlace: suggestion.nearestPlace, distanceToFocus: NSNumber(nonretainedObject: suggestion.distanceToFocus), language: suggestion.language)
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
      let s = W3WObjcSuggestion(words: suggestion.words, country: suggestion.country, nearestPlace: suggestion.nearestPlace, distanceToFocus: NSNumber(nonretainedObject: suggestion.distanceToFocus), language: suggestion.language)
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

