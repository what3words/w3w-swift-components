//
//  File.swift
//  
//
//  Created by Dave Duprey on 14/07/2023.
//
//  This overrides Bundle because it works differently in CocoaPods
//  and Swift Package Manager.  This is an attempt to make it work for both
//

import Foundation


#if SWIFT_PACKAGE
  class W3WBundle: Bundle { }
#else
  class W3WBundle: Bundle {
    static var module: Bundle {
      let podBundle = Bundle(for: Self.self)
      if let bundleURL = podBundle.url(forResource: "W3WComponentResources", withExtension: "bundle") {
        if let bundle = Bundle(url: bundleURL) {
          return bundle
        }
      }
      
      return Bundle.main
    }
  }
#endif


//class W3WBundle: Bundle {
//  static let module: Bundle = {
//    let bundleName = "w3w-swift-components_W3WSwiftComponents"
//
//    let overrides: [URL]
//#if DEBUG
//    if let override = ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_URL"] {
//      overrides = [URL(fileURLWithPath: override)]
//    } else {
//      overrides = []
//    }
//#else
//    overrides = []
//#endif
//
//    let candidates = overrides + [
//      // Bundle should be present here when the package is linked into an App.
//      Bundle.main.resourceURL,
//
//      // Bundle should be present here when the package is linked into a framework.
//      //Bundle(for: BundleFinder.self).resourceURL,
//
//      // For command-line tools.
//      Bundle.main.bundleURL,
//    ]
//
//    for candidate in candidates {
//      let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
//      if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
//        return bundle
//      }
//    }
//    fatalError("unable to find bundle named w3w-swift-components_W3WSwiftComponents")
//  }()
//}
