//
//  LeapMobileSDKDemoApp.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-08.
//

import LeapMobile
import SwiftUI

@main
struct LeapMobileSDKDemoApp: App {

  @State private var initialization: LeapMobileSDK.Initialization = .uninitialized

  var body: some Scene {
    WindowGroup {
      RootView(initialization: $initialization)
        .task {
          await initializeSDKIfNeeded()
        }
    }
  }

  @MainActor
  private func initializeSDKIfNeeded() async {
    guard initialization == .uninitialized else { return }

    let secrets: [Secret: String] = [
      .otaZip: "15bf9cb77aa74de693cd678ebcbbec05",
      .notificationRegistrationApi: "foo",
      .notificationInboxApi: "bar",
      .remoteStateApi: "baz",
      .showclixApi: "biz",
      .accountDeletionApi: "boz"
    ]

    let logger = DemoLogger()
    let analytics = DemoAnalyticsProvider(logger: logger)

    do {
      try await LeapMobileSDK.initialize(
        secrets: secrets,
        metricsProviders: [analytics],
        logging: .logger(logger)
      )
      initialization = LeapMobileSDK.initialization
    } catch {
      logger.error(error)
    }
  }
}
