//
//  DemoViewProvider.swift
//  LeapMobileSDKDemo
//
//  Demo implementation of CustomViewProvider
//

import UIKit

/// Example provider implementation
final class DemoViewProvider: CustomViewProvider {
    
    private var balanceView: CustomBalanceView?
    private var currentBalance: Decimal = 17.08
    private var userInitials: String = "AB"
    
    init() {
        print("DemoViewProvider initialized")
    }
    
    // MARK: - CustomViewProvider
    
    func view(for injectionPoint: ViewInjectionPoint) -> UIView? {
        guard injectionPoint == .topTrailing else { return nil }
        
        let view = CustomBalanceView(balance: currentBalance, userInitials: userInitials)
        balanceView = view
        return view
    }
    
    func viewDidAppear(at injectionPoint: ViewInjectionPoint, view: UIView) {
        print("View appeared at \(injectionPoint.rawValue)")
    }
    
    func viewDidDisappear(at injectionPoint: ViewInjectionPoint, view: UIView) {
        print("View disappeared at \(injectionPoint.rawValue)")
    }
    
    func refreshView(at injectionPoint: ViewInjectionPoint) {
        print("Refresh requested for \(injectionPoint.rawValue)")
        simulateBalanceUpdate()
    }
    
    // MARK: - Demo Methods
    
    func simulateBalanceUpdate() {
        let newBalance = Decimal(Double.random(in: 5.0...50.0))
        currentBalance = newBalance
        balanceView?.updateBalance(newBalance, animated: true)
        print("Balance updated to: \(newBalance)")
    }
}
