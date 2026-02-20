# View Injection POC

## What This Does

Lets host apps inject custom UI (like balance displays) into the SDK.

## How It Works

**1. Create a provider:**
```swift
class MyViewProvider: CustomViewProvider {
    func view(for injectionPoint: ViewInjectionPoint) -> UIView? {
        return CustomBalanceView(balance: 17.08, initials: "AB")
    }
}
```

**2. Pass to SDK:**
```swift
let config = SDKViewInjectionConfiguration(viewProvider: provider)
try await LeapMobileSDK.initialize(..., viewInjectionConfig: config)
```

**3. Done!** Views appear automatically when SDK is shown.

---

## Files

### For SDK (copy these 4 files)
```
SDK/ViewInjection/
├── CustomViewProvider.swift      - Protocol
├── ViewInjectionPoint.swift      - Positions enum
├── SDKViewInjectionConfiguration.swift - Config
└── SDKOverlayContainer.swift     - Container that positions views
```

### Demo (reference only)
```
Demo/
├── CustomBalanceView.swift      - Example view
└── DemoViewProvider.swift       - Example provider
```

---

## SDK Integration

Add one parameter to SDK init:

```swift
public static func initialize(
    secrets: [Secret: String],
    metricsProviders: [AnalyticsProvider],
    logging: LoggingConfiguration,
    viewInjectionConfig: SDKViewInjectionConfiguration? = nil  // NEW
) async throws {
    self.viewInjectionConfiguration = config
}
```

Wrap root VC:

```swift
public static var rootViewController: UIViewController {
    get async throws {
        let contentVC = // ... existing code
        return SDKOverlayContainer.wrap(contentVC, configuration: viewInjectionConfiguration)
    }
}
```

That's it. 2 changes, ~10 lines of code.

---

## Testing

1. Open project in Xcode
2. Drag `SDK/` and `Demo/` folders into project
3. Build & run
4. Tap "Buy Now"
5. See FanCash balance in top-right

---

## Injection Points

```swift
.topTrailing    // Top-right (balance, avatar)
.topLeading     // Top-left
.topCenter      // Top-center
.bottomCenter   // Bottom-center
```

---

## Protocol Methods

All optional (have default implementations):

- `view(for:)` → Return view to show
- `viewDidAppear(at:view:)` → Called when visible
- `viewDidDisappear(at:view:)` → Called when hidden
- `shouldHideView(at:)` → Return true to hide
- `refreshView(at:)` → Update view data

---

**Status:** ✅ POC Complete
