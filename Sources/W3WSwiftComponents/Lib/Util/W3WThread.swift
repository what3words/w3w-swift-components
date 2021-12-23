//
//  File.swift
//
//
//  Created by Dave Duprey on 05/08/2021.
//

import Foundation


class W3WThread {


  static func isMain() -> Bool {
    return Thread.current.isMainThread
  }
  
  
  static func runOnMain(_ block: @escaping () -> ()) {
    if W3WThread.isMain() {
      block()
    } else {
      DispatchQueue.main.async {
        block()
      }
    }
  }

  
  static func runInBackground(_ block: @escaping () -> ()) {
    if Thread.current.qualityOfService == .userInitiated {
      block()
    } else {
      DispatchQueue.global(qos: .userInitiated).async {
        block()
      }
    }
  }

  
}
