//
//  ContentViewModel.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 14/01/26.
//

import DemoSDK
import Combine
import SwiftUI
import WebKit
import UIKit

/// The host app's own URL scheme. Everything else is offered to the SDK.
private let sampleAppScheme = "sampleapp"

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
  private var contentUpdateObserver: NSObjectProtocol?

  /// The view model on screen, for the SDK's external URL handler to reach.
  private static weak var current: ContentViewModel?

  // MARK: - Init
  override init() {
    super.init()
    Self.current = self
    contentUpdateObserver = NotificationCenter.default.addObserver(
      forName: .leapContentUpdateAvailable,
      object: nil,
      queue: .main
    ) { _ in
      // A root built from now on shows the new content. One that is on screen keeps its own.
      print("DEMO: The SDK has newer content. It will show the next time the SDK is opened.")
    }
  }

  // MARK: - External URLs

  /// Every URL the SDK opens outside itself comes here first. The host's own links are handled in
  /// place, without a round trip through the system; the rest the SDK opens as usual.
  static func handleExternalURL(_ url: URL) -> Bool {
    guard url.scheme?.lowercased() == sampleAppScheme, let viewModel = current else { return false }
    viewModel.closeActiveSheet()
    viewModel.isDeepLinkViewPresented = true
    return true
  }
  
  // MARK: - Lifecycle
  
  func onAppear() {
    trackAnalyticsIfNeeded()
  }
  
  // MARK: - User Actions
  
  func openSDK(style: SDKPresentationStyle) {
    Task {
      do {
        let rootVC = try await Leap.makeRootViewController()
        openSDK(with: rootVC, style: style)
      } catch {
        print("DEMO: Couldn't open the SDK: \(error)")
      }
    }
  }

  private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    closeActiveSheet()

    let navController: UINavigationController
    if let existingNav = viewController as? UINavigationController {
      navController = existingNav
    } else {
      navController = UINavigationController(rootViewController: viewController)
    }
    
    navController.delegate = self
    isAtRootScreen = navController.viewControllers.count == 1

    switch style {
    case .bottomSheet:
      activeBottomSheet = Sheet(navController)
    case .fullScreen:
      activeFullScreenSheet = Sheet(navController)
    }
    
  }
  
  @MainActor
  func closeActiveSheet() {
    dismissSheets()
  }
  
  @MainActor
  private func dismissSheets() {
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
    do {
      try Leap.logOut()
    } catch {
      print("DEMO: Couldn't log out: \(error)")
    }
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
    state: Leap.State
  ) {
    if url.scheme?.lowercased() == sampleAppScheme {
      isDeepLinkViewPresented = true
      return
    }

    // Hold on to it until the SDK can say whether it's one of its own.
    guard state == .initialized else {
      pendingDeeplink = url
      return
    }

    guard Leap.canHandleDeepLink(url) else {
      print("DEMO: Not a link the SDK knows: \(url)")
      return
    }

    Task {
      guard let presenter = Self.topMostViewController() else { return }
      do {
        try await Leap.showDeepLink(url, from: presenter)
      } catch {
        print("DEMO: Couldn't show \(url): \(error)")
      }
    }
  }

  /// Walks the presentation stack from the key window's root to find the
  /// view controller the SDK should present the deeplink on.
  private static func topMostViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
  
  func onSDKInitialized() {
    guard let url = pendingDeeplink else { return }
    pendingDeeplink = nil
    handleDeeplink(url, state: .initialized)
  }
  
  // MARK: - Private
  
  private func trackAnalyticsIfNeeded() {
    guard !didTrackAnalytics else { return }
    didTrackAnalytics = true
    
    try? Leap.track(
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
