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
      initializingRootViewController = true
      Task {
        do {
          // See the SDK documentation for why this must be async.
          // Although it's async, creating an instance is cheap and fast.
          sdkRootViewController = try await LeapMobileSDK.rootViewController
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
