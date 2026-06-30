
# Leap Mobile SDK — iOS Integration Guide

This guide covers the steps to integrate, configure, and use the LeapMobile SDK in an iOS application.

---

## Overview

The LeapMobile SDK allows host applications to embed Leap experiences, including navigation, deep link handling, analytics, logging, and SSO authentication.

---

## 1. Initial Setup

### Requirements

- Xcode 16+
- iOS 16+
- Access to the private repository (SSH key or GitHub token)

### Adding the SDK Package

The LeapMobile SDK is distributed as a private Swift Package.

1. Open Xcode.
2. Go to **File > Add Package Dependencies**.
3. Enter the repository SSH URL: `git@github.com:patrontech/LeapMobileSDK-iOS.git`
4. Add the `-ObjC` flag to **Build Settings → Other Linker Flags** for your target. This is required to support the `.nib` files bundled with the SDK.

---

## 2. SDK Usage

### Initialization

The SDK must be initialized before calling any other method. Initialization is asynchronous.

**Required parameters:**

| Parameter | Type |
|---|---|
| `metricsProviders` | `[AnalyticsProvider]` |
| `logging` | `LoggingConfiguration` |

#### Analytics and Logging

- To use a custom logger, implement the `CustomLogger` protocol from the `LeapMobile` module.
- To use a custom analytics provider, implement the `MappedProvider` protocol from the `LeapMobileBase` module.

```swift
let logger = DemoLogger()
let analytics = DemoAnalyticsProvider(logger: logger)
```

#### Example

```swift
try await LeapMobileSDK.initialize(
    metricsProviders: [analytics],
    logging: .logger(logger)
)
```

### Initialization States

The SDK exposes an `initialization` property reflecting its current state:

| State | Description |
|---|---|
| `uninitialized` | Initialization has not started |
| `initializing` | Initialization is in progress |
| `initialized` | Initialization completed successfully |

---

### Presenting the SDK

#### 1. Root Presentation

Retrieve the SDK's `rootViewController` asynchronously and present it using your preferred method (modal, push, etc.).

```swift
func openSDK(style: SDKPresentationStyle) {
    Task {
        let rootVC = try await LeapMobileSDK.rootViewController
        openSDK(with: rootVC, style: style)
    }
}

private func openSDK(with viewController: UIViewController, style: SDKPresentationStyle) {
    closeActiveSheet()
    switch style {
    case .bottomSheet:
        let nav = UINavigationController(rootViewController: viewController)
        activeBottomSheet = Sheet(nav)
    case .fullScreen:
        activeFullScreenSheet = Sheet(viewController)
    }
}
```

> **Note:** Wrapping the root view controller in a `UINavigationController` is recommended. Some internal SDK features require a navigation controller to function correctly. For deep link flows, it may be omitted, as shown in the next section.

#### 2. Deep Links

Call `showDeepLink(_:on:)` asynchronously with the incoming URL and a presenter view controller.

```swift
Task {
    guard let presenter = Self.topMostViewController() else { return }
    try await LeapMobileSDK.showDeepLink(url, on: presenter)
}
```

> If the URL cannot be resolved by the SDK, `showDeepLink(_:on:)` throws `noSuchDeepLink`.

#### 3. WebView Data Store

To share cookies and storage between the host app's web views and SDK web views, use the `.default()` `WKWebsiteDataStore`.

```swift
func openWebView(urlString: String) -> some View {
    let url = URL(string: urlString)!
    let dataStore: WKWebsiteDataStore = .default()
    return CustomWebView(url: url, dataStore: dataStore)
}
```

#### 4. SSO Logout

Call `logoutUser()` to notify the SDK that the current user has been logged out.

```swift
func logoutUser() async throws
```

**Example:**

```swift
Task {
    try await LeapMobileSDK.logoutUser()
}
```

> Documentation for SSO Login and SSO State Listener will be added when these features are available.

---

### Error Handling

All async SDK methods may throw. Handle errors gracefully and provide fallback UI where appropriate.

| Error | Description |
|---|---|
| `sdkNotInitialized` | A method was called before the SDK was initialized |
| `noSuchDeepLink` | The provided deep link URL could not be resolved |
| `sdkInitialized` | A generic error thrown while the SDK was already initialized |
| `sdkInitializing` | A generic error thrown during initialization |

### Common Pitfalls

- Calling SDK methods before initialization completes
- Not wrapping `rootViewController` in a `UINavigationController` when required by internal flows

---

## 3. Push Notifications & Deep Link Testing

The demo app includes built-in tools for testing push notifications and deep link handling.

### In-App Notification Simulator

Tapping any of the notification buttons schedules a local push notification with a deep link payload:

| Button | staging | prod |
|---|---|---|
| 🔔 Schedule | `fanaticssdkstaging://schedule` | `leapfanfest://schedule` |
| 🔔 Talents | `fanaticssdkstaging://talents` | `leapfanfest://talents` |
| 🔔 Brands | `fanaticssdkstaging://brands` | `leapfanfest://brands` |
| 🔔 Sample | `sampleapp://test` | `sampleapp://test` |

**Flow:**
1. Tap a notification button.
2. A local notification is scheduled with a 3-second delay.
3. The notification appears in the notification center.
4. Tap it to reopen the app — the SDK resolves the deep link and displays the appropriate content.

### Notification Permissions

On first launch the app requests notification permissions. If denied, enable them via:

**Settings → Notifications → LeapMobileSDKDemo → Allow Notifications**

### Available Deep Link Schemes

| Scheme | Handler | Examples |
|---|---|---|
| `fanaticssdkstaging://` | LeapMobileSDK | `fanaticssdkstaging://schedule`, `fanaticssdkstaging://talents`, `fanaticssdkstaging://brands` |
| `sampleapp://` | Demo app | `sampleapp://test` |

### Testing with `xcrun simctl openurl`

You can trigger deep links directly from Terminal while the app is running in the booted simulator:

```bash
xcrun simctl openurl booted fanaticssdkstaging://webViewViewTickets
```

Use the same command format for other URLs, for example:

```bash
xcrun simctl openurl booted fanaticssdkstaging://schedule
```

### Testing Flow

1. Build and run the app in the simulator.
2. Grant notification permissions when prompted.
3. Tap a 🔔 button to schedule a test notification.
4. Wait 3 seconds for the notification to appear.
5. Tap the notification to test the deep link flow.

### Debugging Tips

- Check console logs for SDK initialization status and deep link resolution results.
- Verify notification permissions in the Settings app.
- Ensure the SDK is fully initialized before testing deep links.
- Use the "Deeplink" button to manually test URL input
