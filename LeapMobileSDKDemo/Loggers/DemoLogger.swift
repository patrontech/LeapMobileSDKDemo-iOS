//
//  DemoLogger.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-10.
//

import DemoSDK

/// Prints the SDK's log messages. Without a logger the SDK writes nothing anywhere, so this is all
/// of its output.
///
/// Values the SDK marks private are shown only in a Debug build, as Library's own logging does.
struct DemoLogger: Logger {
  #if DEBUG
    private let redactsPrivate = false
  #else
    private let redactsPrivate = true
  #endif

  func log(_ level: LogLevel, category: LogCategory, source: LogSource, content: () -> LogContent) {
    guard level > .verbose else { return }
    print("DEMO: [\(level)] \(category.name) - \(content().fullMessage(redactingPrivate: redactsPrivate))")
  }
}
