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

@MainActor
final class ContentViewModel: NSObject, ObservableObject {
  
  // MARK: - UI State
  @Published var isDeepLinkViewPresented: Bool = false
  @Published var activeBottomSheet: Sheet?
  @Published var activeFullScreenSheet: Sheet?
  @Published var isWebViewPresented: Bool = false
  @Published var isAtRootScreen: Bool = true
  
  // MARK: - View Injection (POC)
  /// The view provider for injecting custom views into the SDK
  /// This demonstrates the POC for allowing host apps to inject UI
  private(set) var viewProvider: DemoViewProvider?
  
  /// Whether view injection is enabled for this demo
  @Published var isViewInjectionEnabled: Bool = true {
    didSet {
      print("🎛️ View injection: \(isViewInjectionEnabled ? "enabled" : "disabled")")
    }
  }
  
  // MARK: - Private
  private var pendingDeeplink: URL?
  private var didTrackAnalytics = false
  
  // MARK: - Init
  override init() {
    super.init()
    setupViewInjection()
  }
  
  // MARK: - View Injection Setup
  
  private func setupViewInjection() {
    // Initialize the view provider
    viewProvider = DemoViewProvider()
    
    // In real SDK integration, the configuration would be passed during SDK init:
    // let config = SDKViewInjectionConfiguration.singlePoint(
    //     viewProvider: viewProvider!,
    //     injectionPoint: .topTrailing
    // )
    // try await LeapMobileSDK.initialize(..., viewInjectionConfig: config)
    
    print("✅ View injection provider initialized")
  }
  
  // MARK: - Lifecycle
  
  func onAppear() {
    trackAnalyticsIfNeeded()
  }
  
  // MARK: - User Actions
  
  func openSDK(style: SDKPresentationStyle) {
    Task {
      let rootVC = try await LeapMobileSDK.rootViewController
      
      // POC: Wrap with view injection if enabled
      let finalVC: UIViewController
      if isViewInjectionEnabled, let provider = viewProvider {
        let config = SDKViewInjectionConfiguration(
          viewProvider: provider,
          enabledPoints: [.topTrailing]
        )
        finalVC = SDKOverlayContainer.wrap(rootVC, configuration: config)
        print("SDK wrapped with view injection")
      } else {
        finalVC = rootVC
        print("SDK presented without view injection")
      }
      
      openSDK(with: finalVC, style: style)
    }
  }
  
  private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    closeActiveSheet()
    
    // Wrap in navigation controller if not already one to enable push navigation
    let navController: UINavigationController
    if let existingNav = viewController as? UINavigationController {
      navController = existingNav
    } else {
      navController = UINavigationController(rootViewController: viewController)
    }
    
    // Set up navigation delegate to track when we're at root
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
  
  // MARK: - Deeplink Handling
  
  func handleDeeplink(
    _ url: URL,
    initialization: LeapMobileSDK.Initialization
  ) {
    closeActiveSheet()
    if let urlScheme = url.scheme?.lowercased(),
       let scheme = DeeplinkScheme(rawValue: urlScheme) {
      switch scheme {
      case .sampleApp:
        isDeepLinkViewPresented = true
      case .leapSDK:
        guard initialization == .initialized else {
          pendingDeeplink = url
          return
        }
        Task {
          let urlResolved = try await LeapMobileSDK.resolveDeepLink(url)
          openSDK(with: urlResolved, style: .bottomSheet)
        }
      }
    }
    
    guard initialization == .initialized else {
      pendingDeeplink = url
      return
    }
    
    Task {
      let urlResolved = try await LeapMobileSDK.resolveDeepLink(url)
      openSDK(with: urlResolved, style: .bottomSheet)
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
  
  // MARK: - View Injection Demo Methods
  
  /// Simulates updating the FanCash balance
  func simulateBalanceUpdate() {
    viewProvider?.simulateBalanceUpdate()
  }
  
  /// Toggles view injection on/off for demonstration
  func toggleViewInjection() {
    isViewInjectionEnabled.toggle()
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
