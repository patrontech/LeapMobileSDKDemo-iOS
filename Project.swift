//  Copyright © 2026 Leap Event Technology. All rights reserved.

import ProjectDescription

// The Demo stands in for a partner's app. It links only DemoSDK, the local package that stands in for
// the partner's SDK package and brings in Library with the `SDKBase` trait (see DemoSDK/Package.swift).

let settings: SettingsDictionary = [
  "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
  "CODE_SIGN_STYLE": "Automatic",
  "DEVELOPMENT_TEAM": "9R3Z39JX3E",
  "ENABLE_PREVIEWS": "YES",
  "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
  "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
  "MARKETING_VERSION": "1.0.0",
  "OTHER_LDFLAGS": "-ObjC",
  "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
  "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
  "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
  "SWIFT_EMIT_LOC_STRINGS": "YES",
  "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
  "SWIFT_VERSION": "5.0",
]

let project = Project(
  name: "LeapMobileSDKDemo",
  organizationName: "Leap Event Technology",
  options: .options(developmentRegion: "en"),
  packages: [
    .package(path: "DemoSDK")
  ],
  targets: [
    .target(
      name: "LeapMobileSDKDemo",
      // iPhone and iPad, plus the iPad app on Apple silicon Macs and Vision Pro, as the Xcode project had.
      destinations: [.iPhone, .iPad, .macWithiPadDesign, .appleVisionWithiPadDesign],
      product: .app,
      bundleId: "com.greencopper.fanaticsfest",
      deploymentTargets: .iOS("26.1"),
      infoPlist: .file(path: "LeapMobileSDKDemo/Info.plist"),
      sources: ["LeapMobileSDKDemo/**/*.swift"],
      resources: ["LeapMobileSDKDemo/Assets.xcassets"],
      dependencies: [
        .package(product: "DemoSDK")
      ],
      settings: .settings(
        base: settings,
        configurations: [
          .debug(name: .debug, settings: ["CURRENT_PROJECT_VERSION": "1"]),
          .release(name: .release, settings: ["CURRENT_PROJECT_VERSION": "3"]),
        ]
      )
    )
  ]
)
