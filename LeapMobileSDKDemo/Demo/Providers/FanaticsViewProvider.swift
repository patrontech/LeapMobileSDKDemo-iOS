//
//  FanaticsViewProvider.swift
//  LeapMobileSDKDemo
//
//  Demo implementation of CustomViewProvider
//

import UIKit

/// Example provider for Fanatics app
final class FanaticsViewProvider: CustomViewProvider {
    
    private var fanCashView: FanCashBalanceView?
    private var currentBalance: Decimal = 17.08
    private var userInitials: String = "AB"
    
    init() {
        print("📦 FanaticsViewProvider initialized")
    }
    
    // MARK: - CustomViewProvider
    
    func view(for injectionPoint: ViewInjectionPoint) -> UIView? {
        guard injectionPoint == .topTrailing else { return nil }
        
        let view = FanCashBalanceView(balance: currentBalance, userInitials: userInitials)
        fanCashView = view
        return view
    }
    
    func viewDidAppear(at injectionPoint: ViewInjectionPoint, view: UIView) {
        print("👁️ View appeared at \(injectionPoint.rawValue)")
        // In real app: fetch latest balance from API
    }
    
    func viewDidDisappear(at injectionPoint: ViewInjectionPoint, view: UIView) {
        print("👋 View disappeared at \(injectionPoint.rawValue)")
    }
    
    func refreshView(at injectionPoint: ViewInjectionPoint) {
        print("🔄 Refresh requested for \(injectionPoint.rawValue)")
        // In real app: fetch latest balance from API
        simulateBalanceUpdate()
    }
    
    // MARK: - Demo Methods
    
    func simulateBalanceUpdate() {
        let newBalance = Decimal(Double.random(in: 5.0...50.0))
        currentBalance = newBalance
        fanCashView?.updateBalance(newBalance, animated: true)
        print("💰 Balance updated to: \(newBalance)")
    }
}
