//
//  ContentViewModel.swift
//  LeapMobileSDKDemo
//
//  Created by Diego Cichello on 14/01/26.
//

import LeapMobile
import Combine
import SwiftUI

import LeapMobile
import SwiftUI

private enum DeeplinkScheme: String {
  case sampleApp = "sampleapp"
  case leapSDK = "fanaticssdkstaging"
}

enum SDKPresentationStyle {
  case fullScreen
  case bottomSheet
}

@MainActor
final class ContentViewModel: ObservableObject {
  
  // MARK: - UI State
  @Published var isSamplePresented: Bool = false
  @Published var activeBottomSheet: Sheet?
  @Published var activeFullScreenSheet: Sheet?
  
  // MARK: - Private
  private var pendingDeeplink: URL?
  private var didTrackAnalytics = false
  
  // MARK: - Init
  init() {}
  
  // MARK: - Lifecycle
  
  func onAppear() {
    trackAnalyticsIfNeeded()
  }
  
  // MARK: - User Actions
  
  func openSDK(style: SDKPresentationStyle) {
    Task {
      let rootVC = try await LeapMobileSDK.rootViewController
      openSDK(with: rootVC, style: style)
    }
  }
  
  private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    closeActiveSheet()
    switch(style) {
    case .bottomSheet:
      let nav = UINavigationController(rootViewController: viewController)
      activeBottomSheet = Sheet(nav)
    case .fullScreen:
      activeFullScreenSheet = Sheet(viewController)
    }
  }
  
  @MainActor
  func closeActiveSheet() {
    activeBottomSheet = nil
    activeFullScreenSheet = nil
    isSamplePresented = false
  }
  
  func openSampleApp() {
    isSamplePresented = true
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
        isSamplePresented = true
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
}
