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
  @State var initialization: LeapMobileSDK.Initialization = .uninitialized

  var body: some Scene {
    WindowGroup {
      ContentView(initialization: $initialization)
        .task {
          guard initialization == .uninitialized else { return }
          let secrets: [Secret: String] = [
            .otaZip: "15bf9cb77aa74de693cd678ebcbbec05",
            // The UI will still function with fake values for these, but it won't be able to communicate with the CMS,
            // though in most cases it should fail gracefully.
            .notificationRegistrationApi: "foo",
            .notificationInboxApi: "bar",
            .remoteStateApi: "baz",
            .showclixApi: "biz",
            .accountDeletionApi: "boz"
          ]
          do {
            try await LeapMobileSDK.initialize(secrets: secrets, logging: .builtin)
            initialization = LeapMobileSDK.initialization
          } catch {
            try? LeapMobileSDK.logger.error(error)
          }
        }
    }
  }
}
