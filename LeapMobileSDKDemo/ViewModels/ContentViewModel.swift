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

@MainActor
final class ContentViewModel: ObservableObject {
  
  // MARK: - UI State
  @Published var isSamplePresented: Bool = false
  @Published var activeSheet: Sheet?
  
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
  
  func openSDK() {
    Task {
      let rootVC = try await LeapMobileSDK.rootViewController
      //let nav = UINavigationController(rootViewController: rootVC)
      activeSheet = Sheet(rootVC)
    }
  }
  
  @MainActor
  func closeActiveSheet() {
    activeSheet = nil
  }
  
  func openSampleApp() {
    isSamplePresented = true
  }
  
  // MARK: - Deeplink Handling
  
  func handleDeeplink(
    _ url: URL,
    initialization: LeapMobileSDK.Initialization
  ) {
    
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
          activeSheet = try await Sheet(
            LeapMobileSDK.resolveDeepLink(url)
          )
        }
      }
    }
    
    guard initialization == .initialized else {
      pendingDeeplink = url
      return
    }
    
    Task {
      activeSheet = try await Sheet(
        LeapMobileSDK.resolveDeepLink(url)
      )
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
