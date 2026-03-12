//
//  ContentViewModel.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 14/01/26.
//

import LeapMobile
import Combine
import SwiftUI
import WebKit
import UIKit

private enum DeeplinkScheme: String {
  case sampleApp = "sampleapp"
  case leapSDK = "fanaticssdkstaging"
}

enum SDKPresentationStyle {
  case fullScreen
  case bottomSheet
}

enum TestNotificationType {
  case rewards
  case events
  case profile
  case sampleApp
}

@MainActor
final class ContentViewModel: NSObject, ObservableObject {
  
  // MARK: - UI State
  @Published var isDeepLinkViewPresented: Bool = false
  @Published var activeBottomSheet: Sheet?
  @Published var activeFullScreenSheet: Sheet?
  @Published var isWebViewPresented: Bool = false
  @Published var isAtRootScreen: Bool = true

  // MARK: - Private
  private var pendingDeeplink: URL?
  private var didTrackAnalytics = false
  
  // MARK: - Init
  override init() {}
  
  // MARK: - Lifecycle
  
  func onAppear() {
    trackAnalyticsIfNeeded()
  }
  
  // MARK: - User Actions
  
  func openSDK(style: SDKPresentationStyle) {
    print("📱 Opening SDK with style: \(style)")
    Task {
      do {
        let rootVC = try await LeapMobileSDK.rootViewController
        print("✅ Got SDK root view controller")
        openSDK(with: rootVC, style: style)
      } catch {
        print("❌ Failed to get SDK root view controller: \(error)")
      }
    }
  }
  
  private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    print("📱 Opening SDK with view controller: \(type(of: viewController))")
    closeActiveSheet()
    
    // Wrap in navigation controller if not already one to enable push navigation
    let navController: UINavigationController
    if let existingNav = viewController as? UINavigationController {
      navController = existingNav
      print("✅ Using existing navigation controller")
    } else {
      navController = UINavigationController(rootViewController: viewController)
      print("✅ Created new navigation controller")
    }
    
    // Set up navigation delegate to track when we're at root
    navController.delegate = self
    isAtRootScreen = navController.viewControllers.count == 1
    
    switch style {
    case .bottomSheet:
      print("📱 Presenting as bottom sheet")
      activeBottomSheet = Sheet(navController)
    case .fullScreen:
      print("📱 Presenting as full screen")
      activeFullScreenSheet = Sheet(navController)
    }
    
    print("✅ SDK presentation triggered")
  }
  
  @MainActor
  func closeActiveSheet() {
    activeBottomSheet = nil
    activeFullScreenSheet = nil
    isDeepLinkViewPresented = false
  }
  
  func openWebView(urlString: String) -> some View {
    let url = URL(string: urlString)!
    let dataStore: WKWebsiteDataStore = .default()
    return CustomWebView(url: url, dataStore: dataStore)
  }
  
  func openDeepLinkView() {
    isDeepLinkViewPresented = true
  }

  func openSSOWebView() {
    isWebViewPresented = true
  }
  
  func logoutUser() {
    /*
     This will be uncommented as soon we have the new SDK on master
    Task {
      try await LeapMobileSDK.logoutUser()
    }
    */
  }
  
  // MARK: - Notification Testing
  
  func sendTestNotification(_ type: TestNotificationType) {
    Task {
      let notificationManager = NotificationManager.shared
      
      do {
        switch type {
        case .rewards:
          try await notificationManager.sendRewardsNotification()
        case .events:
          try await notificationManager.sendEventsNotification()
        case .profile:
          try await notificationManager.sendProfileNotification()
        case .sampleApp:
          try await notificationManager.sendSampleAppNotification()
        }
      } catch {
        print("Failed to send test notification: \(error)")
      }
    }
  }
  
  // MARK: - Deeplink Handling

  func handleDeeplink(
    _ url: URL,
    initialization: LeapMobileSDK.Initialization
  ) {
    print("🔗 Deeplink received: \(url.absoluteString)")
    print("🔗 SDK initialization state: \(initialization)")

    // Check if SDK is initialized
    guard initialization == .initialized else {
      print("⏳ SDK not initialized yet, storing deeplink for later")
      pendingDeeplink = url
      return
    }

    // Parse the URL scheme
    guard let urlScheme = url.scheme?.lowercased() else {
      print("❌ No URL scheme found")
      return
    }

    guard let scheme = DeeplinkScheme(rawValue: urlScheme) else {
      print("❌ Unknown URL scheme: \(urlScheme)")
      return
    }

    // Handle based on scheme type
    switch scheme {
    case .sampleApp:
      print("✅ Demo app deeplink - opening test screen")
      // This is just for the demo app's "Deeplink" button
      // NOT for CMS buttons (those use DemoAppDeepLinkHandler)
      openDeepLinkView()

    case .leapSDK:
      print("🚀 Resolving LeapSDK deeplink...")
      closeActiveSheet()
      Task {
        do {
          let urlResolved = try await LeapMobileSDK.resolveDeepLink(url)
          print("✅ LeapSDK deeplink resolved successfully")
          openSDK(with: urlResolved, style: .bottomSheet)
        } catch {
          print("❌ Failed to resolve LeapSDK deeplink: \(error)")
          print("❌ Error details: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func onSDKInitialized() {
    guard let url = pendingDeeplink else { return }
    pendingDeeplink = nil
    handleDeeplink(url, initialization: .initialized)
  }
  
  // MARK: - Private
  
  private func trackAnalyticsIfNeeded() {
    guard !didTrackAnalytics else { return }
    didTrackAnalytics = true
    
    try? LeapMobileSDK.track(
      DemoEvent(message: "Custom message from demo!")
    )
  }
}

// MARK: - UINavigationControllerDelegate
extension ContentViewModel: UINavigationControllerDelegate {
  nonisolated func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    Task { @MainActor in
      isAtRootScreen = navigationController.viewControllers.count == 1
    }
  }
}
