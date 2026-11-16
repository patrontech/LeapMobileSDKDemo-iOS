// swift-tools-version: 6.2

import PackageDescription

/// Stands in for the package a partner's SDK is built from.
///
/// A partner receives an xcframework built from a package like this one: it embeds the content and the
/// secrets, wraps `Leap.initialize` so the host passes neither, and adds whatever the partner needs on
/// top of Library. Here, the content and secrets are copied in by `scripts/sdk-content`.
///
/// It re-exports `LeapMobileSDK`, which `KIBI-LeapMobile` vends beside `LeapMobile`, and imports
/// `LeapMobile` only internally, so that a host sees nothing of Library but the SDK's own types.
let package = Package(
  name: "DemoSDK",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "DemoSDK", targets: ["DemoSDK"])
  ],
  dependencies: [
    // Library as source, from this workspace. `SDKBase` is the core and the SDK facade, and not one
    // vendor package.
    .package(path: "../../Library", traits: ["SDKBase"])
  ],
  targets: [
    .target(
      name: "DemoSDK",
      dependencies: [
        .product(name: "KIBI-LeapMobile", package: "Library")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
