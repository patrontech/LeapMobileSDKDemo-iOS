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

//struct LeapMobileSDKDemoApp: App {
//  @State var initialization: LeapMobileSDK.Initialization = .uninitialized
//
//  var body: some Scene {
//    WindowGroup {
//      ContentView(initialization: $initialization)
//        .task {
//          guard initialization == .uninitialized else { return }
//          let secrets: [Secret: String] = [
//            .otaZip: "15bf9cb77aa74de693cd678ebcbbec05",
//            // The UI will still function with fake values for these, but it won't be able to communicate with the CMS,
//            // though in most cases it should fail gracefully.
//            .notificationRegistrationApi: "foo",
//            .notificationInboxApi: "bar",
//            .remoteStateApi: "baz",
//            .showclixApi: "biz",
//            .accountDeletionApi: "boz"
//          ]
//          let logger = DemoLogger()
//          let analytics = DemoAnalyticsProvider(logger: logger)
//          do {
//            // You should perform initialization as early as possible in your app's lifecycle.
//            // Initialization is fairly cheap and does not consume a lot of resources, since
//            // most everything is loaded lazily on demand.
//            //
//            // Initialization is highly reliable. If you've set up your project properly, it will
//            // always succeed.
//            try await LeapMobileSDK.initialize(
//              secrets: secrets,
//              metricsProviders: [analytics],
//              logging: .logger(DemoLogger()),
//            )
//            initialization = LeapMobileSDK.initialization
//          } catch {
//            logger.error(error)
//          }
//        }
//    }
//  }
//}
