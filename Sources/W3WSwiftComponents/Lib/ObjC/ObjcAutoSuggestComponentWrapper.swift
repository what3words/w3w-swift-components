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


@objcMembers public class W3WObjcSuggestion: NSObject {
  public var words: String?
  public var country: String?
  public var nearestPlace: String?
  public var distanceToFocus: NSNumber?
  public var language: String?
  
  public init(words: String?, country: String?, nearestPlace: String?, distanceToFocus: NSNumber?, language: String?) {
    self.words            = words
    self.country          = country
    self.nearestPlace     = nearestPlace
    self.distanceToFocus  = NSNumber(nonretainedObject: distanceToFocus)
    self.language         = language
  }
}


@objc public enum W3WObjcInputType: Int {
  case text
  case voconHybrid
  case nmdpAsr
  case genericVoice
  case speechmatics
  case mihup
}


@objcMembers public class W3WObjcOptions: NSObject {
  var options = [W3WOption]()
  
  public func addFocus(_ focus: CLLocationCoordinate2D) {
    options.append(W3WOption.focus(focus))
  }
  
  public func addVoiceLanguage(_ voiceLanguage: String) {
    options.append(W3WOption.voiceLanguage(voiceLanguage))
  }
  
  public func addNumberFocusResults(_ numberFocusResults: Int) {
    options.append(W3WOption.numberFocusResults(numberFocusResults))
  }

  public func addNumberOfResults(_ numberOfResults: Int) {
    options.append(W3WOption.numberOfResults(numberOfResults))
  }

  public func addClipToCountry(_ clipToCountry: String) {
    options.append(W3WOption.clipToCountry(clipToCountry))
  }

  public func addClipToCountries(_ clipToCountries: [String]) {
    options.append(W3WOption.clipToCountries(clipToCountries))
  }

  public func addClipToCircle(_ center:CLLocationCoordinate2D, radius: Double) {
    options.append(W3WOption.clipToCircle(center: center, radius: radius))
  }

  public func addClipToBoxSouthWest(_ southWest:CLLocationCoordinate2D, northEast:CLLocationCoordinate2D) {
    options.append(W3WOption.clipToBox(southWest: southWest, northEast: northEast))
  }

  public func addClipToPolygon(_ clipToPolygon: [CLLocationCoordinate2D]) {
    options.append(W3WOption.clipToPolygon(clipToPolygon))
  }

  public func addPreferLand(_ preferLand: Bool) {
    options.append(W3WOption.preferLand(preferLand))
  }
  
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


@objcMembers
public class W3WObjcAutoSuggestTextField: W3WAutoSuggestTextField {
  
  public func setVoice(_ voice: Bool) {
    set(voice: voice)
  }
  
  public func setFreeformText(_ freeformText: Bool) {
    set(freeformText: freeformText)
  }
  
  public func setAllowInvalid3wa(_ allowInvalid3wa: Bool) {
    set(allowInvalid3wa: allowInvalid3wa)
  }
  
  public func setLanguage(_ l: String) {
    set(language: l)
  }
  
  public func setOptions(_ options: W3WObjcOptions) {
    set(options: options.options)
  }
  
  public func setSuggestionCallback(_ callback: @escaping (W3WObjcSuggestion) -> ()) {
    self.suggestionSelected = { suggestion in
      let s = W3WObjcSuggestion(words: suggestion.words, country: suggestion.country, nearestPlace: suggestion.nearestPlace, distanceToFocus: NSNumber(nonretainedObject: suggestion.distanceToFocus), language: suggestion.language)
      callback(s)
    }
  }
  
  public func setTextChangedCallback(_ callback: @escaping (NSString) -> ()) {
    self.textChanged = { text in
      if let t = text {
        if let ns = NSString(utf8String: t) {
          callback(ns)
        }
      }
    }
  }
  
  public func setErrorCallback(_ callback: @escaping (NSError) -> ()) {
    self.onError = { error in
      callback(NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description]))
    }
  }
  
}



@objcMembers
public class W3WObjcAutoSuggestSearchController: W3WAutoSuggestSearchController {
  
  public func setVoice(_ voice: Bool) {
    set(voice: voice)
  }
  
  public func setFreeformText(_ freeformText: Bool) {
    set(freeformText: freeformText)
  }
  
  public func setAllowInvalid3wa(_ allowInvalid3wa: Bool) {
    set(allowInvalid3wa: allowInvalid3wa)
  }
  
  public func setLanguage(_ l: String) {
    set(language: l)
  }
  
  public func setOptions(_ options: W3WObjcOptions) {
    set(options: options.options)
  }

  public func setSuggestionCallback(_ callback: @escaping (W3WObjcSuggestion) -> ()) {
    self.suggestionSelected = { suggestion in
      let s = W3WObjcSuggestion(words: suggestion.words, country: suggestion.country, nearestPlace: suggestion.nearestPlace, distanceToFocus: NSNumber(nonretainedObject: suggestion.distanceToFocus), language: suggestion.language)
      callback(s)
    }
  }
  
  public func setTextChangedCallback(_ callback: @escaping (NSString) -> ()) {
    self.textChanged = { text in
      if let t = text {
        if let ns = NSString(utf8String: t) {
          callback(ns)
        }
      }
    }
  }
  
  public func setErrorCallback(_ callback: @escaping (NSError) -> ()) {
    self.onError = { error in
      callback(NSError(domain: "w3w", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description]))
    }
  }

}

