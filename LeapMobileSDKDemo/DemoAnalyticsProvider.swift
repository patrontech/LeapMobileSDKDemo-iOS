//
//  LoggingAnalyticsProvider.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-10.
//

import LeapMobile
import LeapMobileBase

extension Provider {
  static let demo: Provider = "demo"
}

extension EventName {
  static let demo: EventName = "demo"
}

struct DemoEvent: MappedMetrics {
  func track(with provider: any MappedProvider) {
    provider.track(event: .demo)
  }
}

struct DemoAnalyticsProvider: MappedProvider {
  let provider: Provider = .demo
  let logger: CustomLogger

  init(logger: CustomLogger) {
    self.logger = logger
//    EventName.screenView[.logging] = "screen_blast"
//    EventName.screenView[.logging] = nil
  }

  func track(event: EventName, parameters: [EventParameter: MappedValue]) {
    guard let event = event[provider] else { return }
    logger.log("ANALYTICS: \(event) has occurred.", level: .info)
  }
  
  func track(user properties: [LeapMobileBase.UserProperty : any LeapMobileBase.MappedValue]) {
    // etc.
  }
}
