// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-updatable",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "Updatable",
      targets: ["Updatable"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-syntax.git",
      "509.0.0"..<"605.0.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-macro-testing.git",
      from: "0.6.0"
    ),
  ],
  targets: [
    .target(
      name: "Updatable",
      dependencies: ["UpdatableMacro"]
    ),
    .macro(
      name: "UpdatableMacro",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "UpdatableMacroTests",
      dependencies: [
        "UpdatableMacro",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    ),
  ]
)
