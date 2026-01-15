//
//  DemoLogger.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-10.
//

import LeapMobile
import LeapMobileBase

struct DemoLogger: CustomLogger {
  func log(
    _ message: String,
    _ file: String,
    _ function: String,
    _ line: Int,
    level: LogLevel,
    tags: [LogTag]
  ) {
    if level <= .verbose { return }
    print("DEMO: \(message)")
  }
}
