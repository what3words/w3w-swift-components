// swift-tools-version:5.3
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
    .package(url: "https://github.com/what3words/w3w-swift-wrapper.git", "3.6.6"..<"4.0.0"),
    //.package(url: "https://github.com/what3words/w3w-swift-wrapper.git", .branch("dd-ascoord")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "W3WSwiftComponents",
      dependencies: [.product(name: "W3WSwiftApi", package: "w3w-swift-wrapper")],
      //resources: [.copy("Resources/flag.water.png"), .copy("Resources/logo.png")]
      resources: [.process("Resources")]
      //resources: [.copy("Resources")]
    ),
    .testTarget(
      name: "w3w-swift-componentsTests",
      dependencies: ["W3WSwiftComponents"]),
  ]
)
