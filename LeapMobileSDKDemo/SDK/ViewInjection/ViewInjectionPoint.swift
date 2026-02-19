//
//  ViewInjectionPoint.swift
//  LeapMobileSDKDemo
//
//  Defines where custom views can be injected
//

import Foundation

/// Available positions for view injection
public enum ViewInjectionPoint: String, CaseIterable {
    case topTrailing    // Top-right corner
    case topLeading     // Top-left corner
    case topCenter      // Top-center
    case bottomCenter   // Bottom-center
}
