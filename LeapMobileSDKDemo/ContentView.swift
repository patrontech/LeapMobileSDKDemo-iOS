//
//  ContentView.swift
//  LeapMobileSDKDemo
//
//  Created by Gregory Higley on 2025-12-08.
//

import LeapMobile
import SwiftUI

struct ContentView: View {
  @Binding var initialization: LeapMobileSDK.Initialization
  @State private var initializingRootViewController = false
  @State private var sdkRootViewController: UIViewController?
  @State private var sheet: Sheet?
  @State private var deeplinkURL: URL?

  var body: some View {
    Group {
      if initialization == .initialized, let sdkRootViewController {
        Button("Present SDK") {
          sheet = Sheet(sdkRootViewController)
        }
      } else {
        ProgressView()
          .progressViewStyle(.circular)
          .controlSize(.large)
          .tint(.blue)
      }
    }
    .sheet(item: $sheet) { sheet in
      NavigationStack {
        sheet.item
      }
    }
    .task {
      // If you're creating the root UI on demand every time it's displayed, then
      // you don't need this code at all. But if you're caching it as in this demo app,
      // then you need some way to apply it.
      for await _ in NotificationCenter.default.notifications(named: .leapMobileOTAAvailable) {
        // If the sdkRootViewController is nil, this means there's no point in
        // re-creating it. It's in process anyway.
        guard !initializingRootViewController, sdkRootViewController != nil else { return }
        do {
          // Re-create the controller to pick up the changes from the OTA.
          sdkRootViewController = try await LeapMobileSDK.rootViewController
        } catch {
          try? LeapMobileSDK.logger.error(error)
        }
      }
    }
    .onOpenURL { url in
      guard initialization == .initialized else {
        deeplinkURL = url
        return
      }
      showDeeplink(url: url)
    }
    .onChange(of: initialization) {
      guard initialization == .initialized, let url = deeplinkURL else { return }
      // This handles the situation where we've received
      // a deeplink URL before initialization has completed.
      deeplinkURL = nil
      showDeeplink(url: url)
    }
    .onChange(of: initialization) {
      guard initialization == .initialized, !initializingRootViewController, sdkRootViewController == nil else {
        return
      }
      // Track some analytics.
      try? LeapMobileSDK.track(DemoEvent(message: "Custom message from demo!"))
      initializingRootViewController = true
      Task {
        do {
          // See the SDK documentation for why this must be async.
          // Although it's async, creating an instance is cheap and fast.
          sdkRootViewController = try await LeapMobileSDK.rootViewController
          initializingRootViewController = false
        } catch {
          try? LeapMobileSDK.logger.error(error)
        }
      }
    }
  }
  
  private func showDeeplink(url: URL) {
    Task {
      sheet = try await Sheet(LeapMobileSDK.resolveDeepLink(url))
    }
  }
}

#Preview {
  ContentView(initialization: .constant(.uninitialized))
}
