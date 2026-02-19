//
//  FanCashBalanceView.swift
//  LeapMobileSDKDemo
//
//  Demo FanCash balance view for POC
//

import UIKit

/// Simple FanCash balance display with avatar
final class FanCashBalanceView: UIView {
    
    // MARK: - Properties
    
    var balance: Decimal = 17.08 {
        didSet { updateBalance() }
    }
    
    var userInitials: String = "AB" {
        didSet { avatarLabel.text = userInitials.uppercased() }
    }
    
    // MARK: - UI Components
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let balanceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let balanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let walletIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wallet.pass.fill")
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .darkText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    convenience init(balance: Decimal, userInitials: String) {
        self.init(frame: .zero)
        self.balance = balance
        self.userInitials = userInitials
        setupView()
        updateBalance()
        avatarLabel.text = userInitials.uppercased()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(containerStack)
        
        balanceContainer.addSubview(balanceStack)
        balanceStack.addArrangedSubview(walletIcon)
        balanceStack.addArrangedSubview(balanceLabel)
        
        avatarContainer.addSubview(avatarLabel)
        
        containerStack.addArrangedSubview(balanceContainer)
        containerStack.addArrangedSubview(avatarContainer)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            balanceStack.topAnchor.constraint(equalTo: balanceContainer.topAnchor, constant: 8),
            balanceStack.leadingAnchor.constraint(equalTo: balanceContainer.leadingAnchor, constant: 12),
            balanceStack.trailingAnchor.constraint(equalTo: balanceContainer.trailingAnchor, constant: -12),
            balanceStack.bottomAnchor.constraint(equalTo: balanceContainer.bottomAnchor, constant: -8),
            
            walletIcon.widthAnchor.constraint(equalToConstant: 16),
            walletIcon.heightAnchor.constraint(equalToConstant: 16),
            
            avatarContainer.widthAnchor.constraint(equalToConstant: 36),
            avatarContainer.heightAnchor.constraint(equalToConstant: 36),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor)
        ])
        
        // Tap to log (demo)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Updates
    
    private func updateBalance() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        balanceLabel.text = formatter.string(from: balance as NSDecimalNumber)
    }
    
    func updateBalance(_ newBalance: Decimal, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.balanceContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                self.balance = newBalance
                UIView.animate(withDuration: 0.2) {
                    self.balanceContainer.transform = .identity
                }
            }
        } else {
            balance = newBalance
        }
    }
    
    @objc private func handleTap() {
        print("💳 FanCash tapped: \(balance)")
    }
}
