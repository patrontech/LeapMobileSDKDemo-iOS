//
//  DemoAppDeepLinkHandler.swift
//  LeapMobileSDKDemo
//

import LeapMobileBase
import UIKit
import SwiftUI

/// Handles deeplinks from CMS buttons configured with mode: "hostApp"
@MainActor
final class DemoAppDeepLinkHandler: DeepLinkHandler {

  func canHandle(_ url: URL) -> Bool {
    // Only handle sampleapp:// URLs that come from CMS
    return url.scheme?.lowercased() == "sampleapp"
  }

  func handleDeepLink(
    _ url: URL,
    context: DeepLinkContext,
    completion: @escaping @MainActor () -> Void
  ) -> Bool {
    guard canHandle(url) else { return false }

    print(" DemoAppDeepLinkHandler: CMS button triggered deeplink")
    print("URL: \(url.absoluteString)")

    // For demo purposes, just show the Deeplink Tests screen
    // In a real app, you'd parse the URL and show different screens
    let view = DeeplinkTestsView(onReturn: completion)
    let hostingController = UIHostingController(rootView: view)
    hostingController.modalPresentationStyle = .fullScreen

    context.sourceViewController.present(hostingController, animated: true)
    return true
  }
}

// MARK: - Simple View with Return Button

private struct DeeplinkTestsView: View {
  let onReturn: () -> Void
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      DeeplinkView()
        .navigationTitle("From CMS Button")
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Back to SDK") {
              dismiss()
              onReturn() // This triggers return to SDK
            }
          }
        }
    }
  }
}
