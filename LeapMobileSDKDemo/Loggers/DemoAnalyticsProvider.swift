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

extension EventParameter {
  static let message: EventParameter = "message"
}

struct DemoEvent: MappedMetrics {
  let message: String?
  
  init(message: String? = nil) {
    self.message = message
  }
  
  func track(with provider: any MappedProvider) {
    var params: [EventParameter: any MappedValue] = [:]
    if let message {
      params[.message] = message
    }
    provider.track(event: .demo, parameters: params)
  }
}

struct DemoAnalyticsProvider: MappedProvider {
  let provider: Provider = .demo
  let logger: CustomLogger

  init(logger: CustomLogger) {
    self.logger = logger
    // Rename an event, just for this analytics provider
//    EventName.screenView[.demo] = "screen_blast"
    // Skip an event, just for this analytics provider
//    EventName.demo[.demo] = nil
  }

  func track(event: EventName, parameters: [EventParameter: MappedValue]) {
    guard let event = event[provider] else { return }
    if event == "demo", let message = parameters[.message] {
      logger.log("ANALYTICS: \(message)", level: .info)
    } else {
      logger.log("ANALYTICS: \(event) has occurred.", level: .info)
    }
    let parameters = parameters.mapKeys { $0[provider] }
    for (param, value) in parameters {
      guard let param else { continue }
      logger.log("ANALYTICS: \(event) PARAM: \(param): \(value)", level: .info)
    }
  }

  // You probably won't need this.
  func track(user properties: [LeapMobileBase.UserProperty : any LeapMobileBase.MappedValue]) {
    // etc.
  }
}
