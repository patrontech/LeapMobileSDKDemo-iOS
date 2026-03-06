//
//  NotificationManager.swift
//  LeapMobileSDKDemo
//

import Foundation
import Combine
import UserNotifications
import UIKit

@MainActor
final class NotificationManager: NSObject, ObservableObject {
  
  static let shared = NotificationManager()
  
  @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
  private var onDeeplinkReceived: ((URL) -> Void)?
  
  override private init() {
    super.init()
  }
  
  // MARK: - Permission Request
  
  func requestAuthorization() async throws {
    let center = UNUserNotificationCenter.current()
    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
    
    if granted {
      let settings = await center.notificationSettings()
      authorizationStatus = settings.authorizationStatus
    }
  }
  
  func checkAuthorizationStatus() async {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()
    authorizationStatus = settings.authorizationStatus
  }
  
  // MARK: - Deeplink Handler
  
  func setDeeplinkHandler(_ handler: @escaping (URL) -> Void) {
    self.onDeeplinkReceived = handler
    UNUserNotificationCenter.current().delegate = self
  }
  
  // MARK: - Test Notifications
  
  func scheduleTestNotification(
    title: String,
    body: String,
    deeplink: String,
    delay: TimeInterval = 3
  ) async throws {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    content.userInfo = ["deeplink": deeplink]
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: trigger
    )
    
    try await UNUserNotificationCenter.current().add(request)
  }
  
  // MARK: - Predefined Test Scenarios
  
  func sendRewardsNotification() async throws {
    try await scheduleTestNotification(
      title: "📅 Check the Schedule!",
      body: "View upcoming events and activities",
      deeplink: "fanaticssdkstaging://schedule"
    )
  }
  
  func sendEventsNotification() async throws {
    try await scheduleTestNotification(
      title: "⭐ Featured Talents",
      body: "Meet your favorite talents and get exclusive access",
      deeplink: "fanaticssdkstaging://talents"
    )
  }
  
  func sendProfileNotification() async throws {
    try await scheduleTestNotification(
      title: "🏢 Explore Brands",
      body: "Discover exclusive brand experiences",
      deeplink: "fanaticssdkstaging://brands"
    )
  }
  
  func sendSampleAppNotification() async throws {
    try await scheduleTestNotification(
      title: "📱 Sample App Deeplink",
      body: "Testing sample app URL scheme",
      deeplink: "sampleapp://test"
    )
  }
  
  func sendCustomNotification(deeplink: String) async throws {
    try await scheduleTestNotification(
      title: "🔗 Custom Deeplink Test",
      body: "Testing: \(deeplink)",
      deeplink: deeplink
    )
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
  
  // Handle notification tap when app is in foreground or background
  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    
    if let deeplinkString = userInfo["deeplink"] as? String,
       let url = URL(string: deeplinkString) {
      Task { @MainActor in
        self.onDeeplinkReceived?(url)
      }
    }
    
    completionHandler()
  }
  
  // Handle notification when app is in foreground
  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.banner, .sound, .badge])
  }
}
