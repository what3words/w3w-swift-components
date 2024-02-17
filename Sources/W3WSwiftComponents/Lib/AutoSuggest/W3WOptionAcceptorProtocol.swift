//
//  File.swift
//  
//
//  Created by Dave Duprey on 05/12/2020.
//

import Foundation
import W3WSwiftCore


/// specifies the different acceptible ways to accept W3WOption, anything conforming
/// to this protocol need only implement set(options: [W3WOption]), and the others
/// are provided by the extension to this protocol
public protocol W3WOptionAcceptorProtocol {

  /// assigns an options object containing various W3WOptions to use on autosuggest calls
  /// - Parameters:
  ///     - options: a W3WOption
  func set(options: W3WOptions)

  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  func set(options: [W3WOption])

  /// assigns an option to use on autosuggest calls
  /// - Parameters:
  ///     - options: a W3WOption
  func set(options: W3WOption)

}


extension W3WOptionAcceptorProtocol {
  
  
  /// assigns an array of options to use on autosuggest calls
  /// - Parameters:
  ///     - options: an array of W3WOption
  public func set(options: W3WOption) {
    set(options: [options])
  }
  
  
  /// assigns an options object containing various W3WOptions to use on autosuggest calls
  /// - Parameters:
  ///     - options: a W3WOption
  public func set(options: W3WOptions) {
    set(options: options.options)
  }

}
