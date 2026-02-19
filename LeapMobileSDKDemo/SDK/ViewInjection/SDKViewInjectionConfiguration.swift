//
//  SDKViewInjectionConfiguration.swift
//  LeapMobileSDKDemo
//
//  Configuration for view injection
//

import Foundation

/// Configuration for view injection
public struct SDKViewInjectionConfiguration {
    
    /// The provider that supplies custom views
    public weak var viewProvider: CustomViewProvider?
    
    /// Which injection points to enable (nil = all enabled)
    public let enabledPoints: Set<ViewInjectionPoint>?
    
    public init(
        viewProvider: CustomViewProvider,
        enabledPoints: Set<ViewInjectionPoint>? = nil
    ) {
        self.viewProvider = viewProvider
        self.enabledPoints = enabledPoints
    }
    
    public func isEnabled(_ point: ViewInjectionPoint) -> Bool {
        guard let points = enabledPoints else { return true }
        return points.contains(point)
    }
}
