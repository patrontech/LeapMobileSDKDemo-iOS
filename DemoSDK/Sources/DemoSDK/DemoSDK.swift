//
//  DemoSDK.swift
//  DemoSDK
//
//  Created by Gregory Higley on 2026-11-09.
//  Copyright © 2026 Leap Event Technology. All rights reserved.
//

// The host sees `LeapMobileSDK` and nothing else of Library's. `LeapMobile`, and every package it
// imports, stays out of this module's interface.
internal import LeapMobile
@_exported import LeapMobileSDK

/// What a partner's SDK looks like to its host: `initialize` takes nothing the host would have to
/// know about. The content, secrets and deep-link scheme are this package's, and the rest of the API
/// is `LeapMobileSDK`'s, re-exported.
public enum DemoSDK {
  @MainActor
  public static func initialize(options: Leap.Options = .init()) async throws {
    try await Leap.initialize(
      .init(resourceBundle: .module, secrets: Secrets.all, deepLinkSchemes: ["fanaticssdkstaging"]),
      options: options,
    )
  }
}
