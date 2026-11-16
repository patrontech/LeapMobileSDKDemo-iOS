//
//  LoggingAnalyticsProvider.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-10.
//

import DemoSDK

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

  init() {
    // Rename an event, just for this analytics provider
//    EventName.screenView[.demo] = "screen_blast"
    // Skip an event, just for this analytics provider
//    EventName.demo[.demo] = nil
  }

  func track(event: EventName, parameters: [EventParameter: MappedValue]) {
    guard let event = event[provider] else { return }
    if event == "demo", let message = parameters[.message] {
      print("ANALYTICS: \(message)")
    } else {
      print("ANALYTICS: \(event) has occurred.")
    }
    for (param, value) in parameters.dictionary(for: provider) {
      print("ANALYTICS: \(event) PARAM: \(param): \(value)")
    }
  }

  // You probably won't need this.
  func track(user properties: [UserProperty: any MappedValue]) {
    // etc.
  }
}
