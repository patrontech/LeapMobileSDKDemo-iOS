//
//  LeapMobileSDKAdapter.swift
//  LeapMobileSDKDemo
//
//  Created by POC - View Injection System
//
//  This file demonstrates how the actual LeapMobileSDK would be modified
//  to support view injection. Since we don't have access to the SDK source,
//  this is a mock implementation showing the integration points.
//

import UIKit

/// Mock adapter showing how LeapMobileSDK would integrate view injection.
///
/// In the real SDK implementation, these changes would be made:
///
/// 1. Add optional `viewInjectionConfig` parameter to `initialize()` method
/// 2. Store the configuration internally
/// 3. Wrap the rootViewController with SDKOverlayContainer when config exists
///
/// ## Example SDK Modification:
///
/// ```swift
/// // In LeapMobileSDK.swift
/// public static func initialize(
///     secrets: [Secret: String],
///     metricsProviders: [AnalyticsProvider],
///     logging: LoggingConfiguration,
///     viewInjectionConfig: SDKViewInjectionConfiguration? = nil  // NEW PARAMETER
/// ) async throws {
///     // ... existing initialization code ...
///
///     // Store configuration for later use
///     self.viewInjectionConfiguration = viewInjectionConfig
/// }
///
/// public static var rootViewController: UIViewController {
///     get async throws {
///         let contentVC = // ... get actual SDK root VC ...
///
///         // Wrap with overlay container if injection is configured
///         return SDKOverlayContainer.wrap(
///             contentVC,
///             configuration: viewInjectionConfiguration
///         )
///     }
/// }
/// ```
///
final class LeapMobileSDKAdapter {
    
    // MARK: - Properties
    
    /// Stored view injection configuration
    private static var viewInjectionConfiguration: SDKViewInjectionConfiguration?
    
    /// Mock SDK root view controller (in real SDK, this would be the actual content)
    private static var mockRootViewController: UIViewController?
    
    // MARK: - Mock SDK Methods
    
    /// Mock version of LeapMobileSDK.initialize() with view injection support
    static func initializeSDK(
        viewInjectionConfig: SDKViewInjectionConfiguration? = nil
    ) async throws {
        // Store the configuration
        self.viewInjectionConfiguration = viewInjectionConfig
        
        print("🚀 SDK initialized with view injection: \(viewInjectionConfig != nil)")
    }
    
    /// Mock version of LeapMobileSDK.rootViewController that wraps with overlay
    static func getRootViewController(baseViewController: UIViewController) -> UIViewController {
        // This demonstrates how the SDK would wrap its content VC
        return SDKOverlayContainer.wrap(
            baseViewController,
            configuration: viewInjectionConfiguration
        )
    }
}

// MARK: - Extension for ContentViewModel

extension ContentViewModel {
    
    /// Modified version of openSDK that uses the adapter to wrap the view controller
    ///
    /// This demonstrates how the host app would use the SDK's rootViewController
    /// which is already wrapped with the overlay container.
    func openSDKWithInjection(
        baseViewController: UIViewController,
        style: SDKPresentationStyle
    ) {
        closeActiveSheet()
        
        // In real implementation, you'd just call:
        // let rootVC = try await LeapMobileSDK.rootViewController
        // The SDK would internally wrap it with SDKOverlayContainer
        
        let wrappedVC = LeapMobileSDKAdapter.getRootViewController(
            baseViewController: baseViewController
        )
        
        // Wrap in navigation controller if needed
        let navController: UINavigationController
        if let existingNav = wrappedVC as? UINavigationController {
            navController = existingNav
        } else {
            navController = UINavigationController(rootViewController: wrappedVC)
        }
        
        // Set up navigation delegate
        navController.delegate = self
        isAtRootScreen = navController.viewControllers.count == 1
        
        switch style {
        case .bottomSheet:
            activeBottomSheet = Sheet(navController)
        case .fullScreen:
            activeFullScreenSheet = Sheet(navController)
        }
    }
}


