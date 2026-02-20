//
//  CustomViewProvider.swift
//  LeapMobileSDKDemo
//
//  Protocol for host apps to provide custom views
//

import UIKit

/// Host apps implement this to inject custom views into the SDK
public protocol CustomViewProvider: AnyObject {
    /// Return a view to inject, or nil
    func view(for injectionPoint: ViewInjectionPoint) -> UIView?
    
    /// Called when view appears (optional)
    func viewDidAppear(at injectionPoint: ViewInjectionPoint, view: UIView)
    
    /// Called when view disappears (optional)
    func viewDidDisappear(at injectionPoint: ViewInjectionPoint, view: UIView)
    
    /// Return true to hide view (optional)
    func shouldHideView(at injectionPoint: ViewInjectionPoint) -> Bool
    
    /// Called to refresh view data (optional)
    func refreshView(at injectionPoint: ViewInjectionPoint)
}

// Default implementations (makes methods optional)
public extension CustomViewProvider {
    func view(for injectionPoint: ViewInjectionPoint) -> UIView? { nil }
    func viewDidAppear(at injectionPoint: ViewInjectionPoint, view: UIView) { }
    func viewDidDisappear(at injectionPoint: ViewInjectionPoint, view: UIView) { }
    func shouldHideView(at injectionPoint: ViewInjectionPoint) -> Bool { false }
    func refreshView(at injectionPoint: ViewInjectionPoint) { }
}
