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
  @State private var deeplinkToHandle: URL?

  var body: some Scene {
    WindowGroup {
      RootView(initialization: $initialization, deeplinkToHandle: $deeplinkToHandle)
        .task {
          await initializeSDKIfNeeded()
          await setupNotifications()
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

      // Trigger OTA check immediately after initialization
      logger.info("Triggering OTA check after initialization")
      NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
    } catch {
      logger.error(error)
    }
  }

  @MainActor
  private func setupNotifications() async {
    let notificationManager = NotificationManager.shared

    // Request notification permissions
    try? await notificationManager.requestAuthorization()
    await notificationManager.checkAuthorizationStatus()

    // Set up deeplink handler from notifications
    notificationManager.setDeeplinkHandler { [self] url in
      deeplinkToHandle = url
    }
  }
}
