//
//  BaseViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import UIKit


class BaseViewController<V: BaseViewModelProtocol>: UIViewController {
    
    var viewModel: V
    
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    init(viewModel: V) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContents()
        subscribeLoading()
    }
    
    private func configureContents() {
        view.backgroundColor = .white
    }
    
#if DEBUG
    deinit {
        debugPrint("deinit \(self)")
    }
#endif
}

// MARK: - Loading
extension BaseViewController {
    
    private func subscribeLoading() {
        viewModel.showLoading = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showActivityIndicator()
            }
        }
        
        viewModel.hideLoading = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
        }
    }
    
    private func showActivityIndicator() {

        guard loadingView == nil else { return }
        
        loadingView = UIView()
        loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        activityIndicator?.color = .white
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.startAnimating()
        
        guard let loadingView = loadingView,
              let activityIndicator = activityIndicator else { return }
        
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
        
        loadingView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            loadingView.alpha = 1
        }
    }
    
    private func hideActivityIndicator() {
        guard let loadingView = loadingView else { return }
        UIView.animate(withDuration: 0.3, animations: {
            loadingView.alpha = 0
        }) { _ in
            self.activityIndicator?.stopAnimating()
            loadingView.removeFromSuperview()
            self.loadingView = nil
            self.activityIndicator = nil
        }
    }
}


