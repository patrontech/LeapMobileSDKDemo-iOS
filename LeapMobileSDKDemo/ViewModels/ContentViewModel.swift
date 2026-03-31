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
  override init() {
    super.init()
    setupSDKPresentationManager()
  }
  
  private func setupSDKPresentationManager() {
    LeapMobileSDK.presentationManager.setRestorationHandler { [weak self] style, viewController in
      guard let self = self else { return }
      let localStyle: SDKPresentationStyle = style == .bottomSheet ? .bottomSheet : .fullScreen
      self.openSDK(with: viewController, style: localStyle, shouldCloseFirst: false)
    }
  }
  
  // MARK: - Lifecycle
  
  func onAppear() {
    trackAnalyticsIfNeeded()
  }
  
  // MARK: - User Actions
  
  func openSDK(style: SDKPresentationStyle) {
    Task {
      do {
        let rootVC = try await LeapMobileSDK.rootViewController
        openSDK(with: rootVC, style: style)
      } catch {
      }
    }
  }
  
  private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    openSDK(with: viewController, style: style, shouldCloseFirst: true)
  }
  
  private func openSDK(
    with viewController: UIViewController, 
    style: SDKPresentationStyle,
    shouldCloseFirst: Bool
  ) {
    
    if shouldCloseFirst {
      closeActiveSheet()
    }
    
    let navController: UINavigationController
    if let existingNav = viewController as? UINavigationController {
      navController = existingNav
    } else {
      navController = UINavigationController(rootViewController: viewController)
    }
    
    navController.delegate = self
    isAtRootScreen = navController.viewControllers.count == 1
    
    let presentationStyle: SDKPresentationManager.PresentationStyle = style == .bottomSheet ? .bottomSheet : .fullScreen
    LeapMobileSDK.presentationManager.recordPresentation(
      style: presentationStyle,
      viewController: navController
    )
    
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
    
    LeapMobileSDK.presentationManager.clearPreservedState()
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
    
    // Parse the URL scheme first to determine behavior
    guard let urlScheme = url.scheme?.lowercased() else {
      return
    }
    
    guard let scheme = DeeplinkScheme(rawValue: urlScheme) else {
      return
    }
    
    // Check if SDK is initialized
    guard initialization == .initialized else {
      pendingDeeplink = url
      return
    }
    
    // Handle based on scheme type
    switch scheme {
    case .sampleApp:

      isDeepLinkViewPresented = true
      
    case .leapSDK:
      closeActiveSheet()
      Task {
        do {
          let urlResolved = try await LeapMobileSDK.resolveDeepLink(url)
          openSDK(with: urlResolved, style: .bottomSheet)
        } catch {
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
