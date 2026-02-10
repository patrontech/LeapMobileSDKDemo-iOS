
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
- File with assets and initial content

### Installation

## Assets / Initial Content

1. `content_vN.zip` and `runConfig.json`. Do not unzip `content_vN.zip`.
2. Unzip `images_full_vN.zip` into a folder so that you can delete and replace it later when you get a new version.
3. Do **not** put `buildConfig.json` anywhere in the code. You'll need to reference this file, but it should **never** end up in the build.
4. This content, including images, must be bundled with the app to ensure offline support.

## SDK Integration

LeapMobile SDK is distributed as a private Swift Package.

### Steps

1. Open Xcode
2. Go to **File > Add Packages**
3. Search for the repository SSH url:
   <git@github.com:patrontech/LeapMobileSDK-iOS.git>
4. To support the .nib files included in the SDK, you must add the -ObjC flag under Build Settings → Other Linker Flags for your target.

# 2. Steps to run the SDK

## SDK Initialization

The SDK must be initialized before any other method is called. Due to internal SDK constraints, the initialization process must be performed asynchronously.

### Required Parameters

- `secrets`: `[Secret: String]`
- `metricsProviders`: `[AnalyticsProvider]`
- `logging`: `LoggingConfiguration`

## Secrets

1. The first parameter requires some configuration ids and information that need to be exported in this secrets collection. This particular example is the one that we used inside our sample app.
2. A more detailed documentation for those parameters will be created.
 
``` swift
    let secrets: [Secret: String] = [
      .otaZip: "15bf9cb77aa74de693cd678ebcbbec05",
      .notificationRegistrationApi: "foo",
      .notificationInboxApi: "bar",
      .remoteStateApi: "baz",
      .showclixApi: "biz",
      .accountDeletionApi: "boz"
    ]
```

## Analytics and Logging

1. If you want a custom logger or to wrap an existing logger from the target codebase, implement the `CustomLogger` protocol from the `LeapMobile` module. A more detailed documentation will be created for this.
2. If you want a custom analytics provider, implement the `MappedProvider` protocol from the `LeapMobileBase` module. A more detailed documentation will be created for this.

``` swift
    let logger = DemoLogger()
    let analytics = DemoAnalyticsProvider(logger: logger)
```

### Example from sample app of initialization

``` swift
    try await LeapMobileSDK.initialize(
        secrets: secrets,
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

3. SSO Login
  This part of the documentation will be done when we develop this feature.

4. SSO Logout
  This part of the documentation will be done when we develop this feature.

5. SSO State Listener
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
