//
//  File.swift
//  
//
//  Created by Dave Duprey on 16/02/2024.
//

import Foundation


//
//  File.swift
//
//
//  Created by Dave Duprey on 06/07/2020.
//

import Foundation


public typealias W3WTextDebouncer = W3WDebouncerPlus<String>


/// calls a closure no faster than a certain frequency
public class W3WDebouncerPlus<T> {
  private let delay: TimeInterval
  private var timer: Timer?

  public var handler: (T) -> Void

  public init(delay: TimeInterval, handler: @escaping (T) -> Void) {
    self.delay = delay
    self.handler = handler
  }


  public func call(_ value: T) {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in  self?.handler(value)})
  }


  func invalidate() {
    timer?.invalidate()
    timer = nil
  }
}
