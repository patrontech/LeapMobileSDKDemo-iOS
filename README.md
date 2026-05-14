
# LeapMobile SDK Usage - Setup Guide

This guide covers the required steps to integrate and run the LeapMobile SDK in an iOS application.

---

## Overview

LeapMobile SDK allows host applications to embed Leap experiences inside their app, including navigation, deep link handling, analytics, logging, and SSO authentication.

# 1. Initial Setup

### Requirements
- Xcode 16+ 
- iOS 16+
- Access to the private repository (SSH key or GitHub token)

## SDK Integration

LeapMobile SDK is distributed as a private Swift Package.

### Steps

1. Open Xcode
2. Go to **File > Add Package Dependecies**
3. Search for the repository SSH url:
   <git@github.com:patrontech/LeapMobileSDK-iOS.git>
4. To support the .nib files included in the SDK, you must add the -ObjC flag under Build Settings → Other Linker Flags for your target.

# 2. Steps to run the SDK

## SDK Initialization

The SDK must be initialized before any other method is called. Due to internal SDK constraints, the initialization process must be performed asynchronously.

### Required Parameters

- `metricsProviders`: `[AnalyticsProvider]`
- `logging`: `LoggingConfiguration`

## Analytics and Logging

1. If you want a custom logger or to wrap an existing logger from the target codebase, implement the `CustomLogger` protocol from the `LeapMobile` module. A more detailed documentation will be created for this.
2. If you want a custom analytics provider, implement the `MappedProvider` protocol from the `LeapMobileBase` module. A more detailed documentation will be created for this.

``` swift
    let logger = DemoLogger()
    let analytics = DemoAnalyticsProvider(logger: logger)
```

### Example of the initialization from the sample app

``` swift
    try await LeapMobileSDK.initialize(
        metricsProviders: [analytics],
        logging: .logger(logger)
      )
```

## States of the initialization

The SDK have a property called initialization that return what is the state of the SDK based on its initialization. It can be three different states:
1. uninitialized -> When the SDK still have not started the initialization
2. initializing -> When the SDK is in the middle of the process to initialize
3. initialized -> When the SDK have finished initializing.


## Usage of the SDK

After the SDK was initialized you can use some of the methods to be able to show the SDK on your application.

1. Root Presentation

The SDK provides a main rootViewController that serves as its entry point. Retrieve it asynchronously, then present it using your preferred navigation method (modal, push, etc.). In our example, the SDK is presented modally.

``` swift
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
```

In this particular example from our sample app, it shows that you might or not embed our SDK Root View Controller in a navigation controller. If its embedded it will have an extra bar that may be used for some of our features. Some internal features may require a NavigationController to be able to be reached as well. So it's a good practice to have this implemented. But for some cases as Deeplinks you might not need as we are going to show in the next example.

2. Deeplinks

The SDK provides a mechanism to resolve and handle deep links received by the host application. You need to call the resolvedDeepLink method asynchronous and wait for its response. If a deeplink was not able to be resolved it will return a nil view controller so remember to take this in consideration when implemented.

``` swift
        Task {
          let urlResolved = try await LeapMobileSDK.resolveDeepLink(url)
          openSDK(with: urlResolved, style: .bottomSheet)
        }
  
```

3. Webview DataStore

To share information between webviews from the main app and the SDK, we need some configuration needed for the usage of the webview. The WKWebsiteDataStore needs to be set for the .default one. So we can guarantee its going to be shared to any webview opened inside the SDK. Here is the sample method we used to show this:

```swift
    func openWebView(urlString: String) -> some View {
    let url = URL(string: urlString)!
    let dataStore: WKWebsiteDataStore = .default()
    return CustomWebView(url: url, dataStore: dataStore)
  }
``

4. SSO Login
  This part of the documentation will be done when we develop this feature.

5. SSO Logout
  This part of the documentation will be done when we develop this feature.

6. SSO State Listener
  This part of the documentation will be done when we develop this feature.
  
 
  
## Error Handling

All async SDK methods may throw errors.
Make sure to handle errors gracefully and provide fallback UI to the user.

The types of error that the SDK might throw are the ones listed here:

1. sdkNotInitialized -> Error that is throw if you want to use a function of the SDK that needs it to be initialized but it's not.
2. noSuchDeepLink -> Error that is throw if you a deeplink was not found inside the SDK resolver.
3. sdkInitialized -> This is a generic error if an error was thrown while the sdk was already initialized.
4. sdkInitializing -> This is a generic error if an error was thrown while the sdk was initializing.

## Common Pitfalls

- Forgetting to initialize the SDK before accessing any method
- Shipping `buildConfig.json` in the app bundle
- Not embedding the rootViewController in a UINavigationController when required by internal flows

---

# 3. Push Notifications & Deeplink Testing

This demo app includes built-in tools to test push notifications and deeplink handling.

## In-App Notification Simulator

The app includes filter chip buttons that trigger local push notifications with deeplink payloads:

- **🔔 Schedule** - Sends a notification that opens `leapfanfest://scheduleList`
- **🔔 Talents** - Sends a notification that opens `leapfanfest://talents`
- **🔔 Brands** - Sends a notification that opens `leapfanfest://brands`
- **🔔 Sample** - Sends a notification that opens `sampleapp://test`

### How it works:

1. Tap any notification test button
2. A local notification will be scheduled (3 second delay)
3. The notification appears in the notification center
4. Tap the notification to open the app with the deeplink
5. The SDK resolves the deeplink and displays the appropriate content

### Permission Handling

On first launch, the app automatically requests notification permissions. If denied, you can enable them in:
**Settings app → Notifications → LeapMobileSDKDemo → Allow Notifications**

## Available Deeplink Schemes

1. **LeapSDK Scheme**: `leapfanfest://`
   - Resolves through the LeapMobileSDK
   - Examples: `leapfanfest://schedule`, `leapfanfest://talents`, `leapfanfest://brands`

2. **Sample App Scheme**: `sampleapp://`
   - Opens the demo deeplink view
   - Example: `sampleapp://test`

## Testing Flow

1. Build and run the app in simulator
2. Grant notification permissions when prompted
3. Tap any "🔔" button to schedule a test notification
4. Wait 3 seconds for the notification to appear
5. Tap the notification to test the deeplink flow

### Debugging Tips:
- Check console logs for SDK initialization status and deeplink processing
- Verify notification permissions in Settings app
- Ensure SDK is fully initialized before testing deeplinks
- Use the "Deeplink" button to manually test URL input
