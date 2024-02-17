// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
  name: "w3w-swift-components",
  defaultLocalization: "en",
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "W3WSwiftComponents",
      targets: ["W3WSwiftComponents"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/what3words/w3w-swift-wrapper.git", branch: "v4/main"), //"4.0.0"..<"5.0.0"),
    .package(url: "https://github.com/what3words/w3w-swift-core.git", "1.0.0"..<"2.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "W3WSwiftComponents",
      dependencies: [.product(name: "W3WSwiftApi", package: "w3w-swift-wrapper"), .product(name: "W3WSwiftCore", package: "w3w-swift-core")],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "w3w-swift-componentsTests",
      dependencies: ["W3WSwiftComponents"]),
  ]
)
