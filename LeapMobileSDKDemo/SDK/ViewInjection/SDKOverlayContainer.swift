//
//  SDKOverlayContainer.swift
//  LeapMobileSDKDemo
//
//  Created by POC - View Injection System
//

import UIKit

/// A container view controller that wraps the SDK's root view controller and manages
/// overlaid custom views from the host application.
///
/// This class is responsible for:
/// - Hosting the SDK's main content view controller
/// - Positioning and managing injected custom views
/// - Handling view lifecycle and updates
/// - Coordinating animations and transitions
///
/// - Note: This is an internal SDK component. Host apps interact with it indirectly
///   through the `CustomViewProvider` protocol and configuration.
public final class SDKOverlayContainer: UIViewController {
    // MARK: - Properties
    
    /// The SDK's actual content view controller
    private let contentViewController: UIViewController
    
    /// Configuration for view injection behavior
    private let configuration: SDKViewInjectionConfiguration
    
    /// Cached injected views by their injection point
    private var injectedViews: [ViewInjectionPoint: UIView] = [:]
    
    /// Observer for app lifecycle events
    private var foregroundObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    
    /// Creates a new overlay container wrapping the SDK's content.
    ///
    /// - Parameters:
    ///   - contentViewController: The SDK's root view controller to wrap
    ///   - configuration: View injection configuration
    public init(
        contentViewController: UIViewController,
        configuration: SDKViewInjectionConfiguration
    ) {
        self.contentViewController = contentViewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupContentViewController()
        setupInjectedViews()
        setupLifecycleObservers()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notifyViewsAppeared()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notifyViewsDisappeared()
    }
    
    // MARK: - Setup
    
    private func setupContentViewController() {
        // Add content view controller as child
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        
        // Setup constraints to fill entire container
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentViewController.didMove(toParent: self)
    }
    
    private func setupInjectedViews() {
        guard let provider = configuration.viewProvider else { return }
        
        // Request views for all enabled injection points
        for injectionPoint in ViewInjectionPoint.allCases {
            guard configuration.isEnabled(injectionPoint) else { continue }
            
            if let customView = provider.view(for: injectionPoint) {
                addInjectedView(customView, at: injectionPoint)
            }
        }
    }
    
    private func setupLifecycleObservers() {
        // Auto-refresh on foreground (always enabled for simplicity)
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshAllViews()
        }
    }
    
    // MARK: - View Management
    
    private func addInjectedView(_ customView: UIView, at injectionPoint: ViewInjectionPoint) {
        // Store reference
        injectedViews[injectionPoint] = customView
        
        // Add to view hierarchy
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        // Apply positioning constraints
        applyConstraints(for: customView, at: injectionPoint)
        
        // Initial visibility state
        let shouldHide = configuration.viewProvider?.shouldHideView(at: injectionPoint) ?? false
        customView.isHidden = shouldHide
        
        // Animate appearance
        if !shouldHide {
            animateViewAppearance(customView)
        }
    }
    
    private func applyConstraints(for view: UIView, at injectionPoint: ViewInjectionPoint) {
        let padding: CGFloat = 16
        let safeArea = self.view.safeAreaLayoutGuide
        
        switch injectionPoint {
        case .topTrailing:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
                view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding)
            ])
            
        case .topLeading:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
                view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding)
            ])
            
        case .topCenter:
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
                view.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
            ])
            
        case .bottomCenter:
            NSLayoutConstraint.activate([
                view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -padding),
                view.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
            ])
        }
    }
    
    // MARK: - Animations
    
    private func animateViewAppearance(_ view: UIView) {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                view.alpha = 1
                view.transform = .identity
            }
        )
    }
    
    // MARK: - Lifecycle Notifications
    
    private func notifyViewsAppeared() {
        guard let provider = configuration.viewProvider else { return }
        
        for (point, view) in injectedViews where !view.isHidden {
            provider.viewDidAppear(at: point, view: view)
        }
    }
    
    private func notifyViewsDisappeared() {
        guard let provider = configuration.viewProvider else { return }
        
        for (point, view) in injectedViews {
            provider.viewDidDisappear(at: point, view: view)
        }
    }
    
    // MARK: - Public API
    
    /// Refreshes all injected views by calling the provider's refresh method.
    public func refreshAllViews() {
        guard let provider = configuration.viewProvider else { return }
        
        for point in injectedViews.keys {
            provider.refreshView(at: point)
        }
    }
    
    /// Updates visibility of injected views based on provider's current state.
    public func updateViewVisibility() {
        guard let provider = configuration.viewProvider else { return }
        
        for (point, view) in injectedViews {
            let shouldHide = provider.shouldHideView(at: point)
            
            UIView.animate(withDuration: 0.25) {
                view.isHidden = shouldHide
            }
        }
    }
    
    /// Removes and re-adds an injected view at the specified point.
    ///
    /// Useful when the view needs to be completely recreated.
    ///
    /// - Parameter injectionPoint: The point to refresh
    public func reloadView(at injectionPoint: ViewInjectionPoint) {
        // Remove existing view
        if let existingView = injectedViews[injectionPoint] {
            existingView.removeFromSuperview()
            injectedViews.removeValue(forKey: injectionPoint)
        }
        
        // Request new view from provider
        guard let provider = configuration.viewProvider,
              let newView = provider.view(for: injectionPoint) else {
            return
        }
        
        addInjectedView(newView, at: injectionPoint)
    }
}

// MARK: - Factory

public extension SDKOverlayContainer {
    
    /// Creates an overlay container if view injection is configured, otherwise returns
    /// the content view controller directly.
    ///
    /// - Parameters:
    ///   - contentViewController: The SDK's root view controller
    ///   - configuration: Optional view injection configuration
    /// - Returns: Either an overlay container or the content VC directly
    static func wrap(
        _ contentViewController: UIViewController,
        configuration: SDKViewInjectionConfiguration?
    ) -> UIViewController {
        guard let config = configuration else {
            return contentViewController
        }
        
        return SDKOverlayContainer(
            contentViewController: contentViewController,
            configuration: config
        )
    }
}


