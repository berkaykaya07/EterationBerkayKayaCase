//
//  ToastHelper.swift
//  deneme
//
//  Created by Berkay on 19.08.2025.
//

import UIKit

final class ToastHelper {
    
    enum ToastType {
        case success
        case error
        case info
        case warning
        
        var backgroundColor: UIColor {
            switch self {
            case .success:
                return UIColor.appBlue
            case .error:
                return UIColor.systemRed
            case .info:
                return UIColor.systemBlue
            case .warning:
                return UIColor.systemOrange
            }
        }
    }
    
    static func showToast(
        in view: UIView,
        message: String,
        type: ToastType = .success,
        duration: TimeInterval = 1.5,
        bottomOffset: CGFloat = -100
    ) {
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = type.backgroundColor.withAlphaComponent(0.9)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.montserratMedium(size: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 2
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomOffset),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Convenience Methods
    static func showSuccess(in view: UIView, message: String) {
        showToast(in: view, message: message, type: .success)
    }
    
    static func showError(in view: UIView, message: String) {
        showToast(in: view, message: message, type: .error)
    }
    
    static func showInfo(in view: UIView, message: String) {
        showToast(in: view, message: message, type: .info)
    }
    
    static func showWarning(in view: UIView, message: String) {
        showToast(in: view, message: message, type: .warning)
    }
    
    // MARK: - Cart Specific Methods
    static func showAddToCartSuccess(in view: UIView, productName: String) {
        let message = "\(productName) added to cart!"
        showSuccess(in: view, message: message)
    }
    
    static func showRemoveFromCartSuccess(in view: UIView, productName: String) {
        let message = "\(productName) removed from cart!"
        showError(in: view, message: message)
    }
}
