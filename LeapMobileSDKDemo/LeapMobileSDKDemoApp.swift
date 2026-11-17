//
//  LeapMobileSDKDemoApp.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-08.
//

import DemoSDK
import SwiftUI

@main
struct LeapMobileSDKDemoApp: App {

  @State private var state: Leap.State = .uninitialized
  @State private var deeplinkToHandle: URL?

  var body: some Scene {
    WindowGroup {
      RootView(state: $state, deeplinkToHandle: $deeplinkToHandle)
        .task {
          await initializeSDKIfNeeded()
          await setupNotifications()
        }
    }
  }

  @MainActor
  private func initializeSDKIfNeeded() async {
    guard state == .uninitialized else { return }

    let logger = DemoLogger()
    let analytics = DemoAnalyticsProvider()

    do {
      // The host passes no content and no secrets: those are DemoSDK's.
      try await DemoSDK.initialize(
        options: .init(
          logger: logger,
          analyticsProviders: [analytics],
          externalURLHandler: ContentViewModel.handleExternalURL,
        )
      )
    } catch {
      logger.error("SDK initialization failed", error: error)
    }
    state = Leap.state
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
