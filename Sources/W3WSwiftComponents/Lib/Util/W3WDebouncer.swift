//
//  File.swift
//
//
//  Created by Dave Duprey on 06/07/2020.
//

import Foundation



/// calls a closure no faster than a certain frequency
public class W3WDebouncer {
  private let delay: TimeInterval
  private var timer: Timer?

  public var handler: () -> Void

  public init(delay: TimeInterval, handler: @escaping () -> Void) {
    self.delay = delay
    self.handler = handler
  }


  public func call() {
    if #available(iOS 10.0, *) {
      timer?.invalidate()
      timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in  self?.handler()})
    } else {
      timer?.invalidate()
      timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(callTheBlock), userInfo: nil, repeats: false)
    }
  }

  /// This is for iOS 9 and earlier compatibility
  @objc
  func callTheBlock() {
    self.handler()
  }

  
  func invalidate() {
    timer?.invalidate()
    timer = nil
  }
}
