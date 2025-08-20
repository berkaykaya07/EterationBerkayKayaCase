//
//  ProductDetailViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class ProductDetailViewController: BaseViewController<ProductDetailViewModel> {
    
    // MARK: - UI Elements
    private let backButton = UIButton(type: .custom)
    private let headerLabel = UILabel()
    private let productImageView = UIImageView()
    private let fovoriteButton = UIButton(type: .system)
    private let productTitleLabel = UILabel()
    private let productDescriptionLabel = UILabel()
    private let priceStackView = UIStackView()
    private let priceLabel = UILabel()
    private let priceValueLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContents()
        subscribeViewModel()
        setupNotificationObservers()
        updateFavoriteButtonState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UILayout
private extension ProductDetailViewController {
    
    private func setupUI() {
        addBackButton()
        addHeaderLabel()
        addProductImageView()
        addFavouriteButton()
        addProductTitleLabel()
        addProductDescriptionLabel()
        addPriceStackView()
        addAddToCartButton()
     }
    
    private func addBackButton() {
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func addHeaderLabel() {
        self.navigationItem.titleView = headerLabel
    }
    
    private func addProductImageView() {
        self.view.addSubview(productImageView)
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            productImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            productImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            productImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.26)
        ])
    }
    
    private func addFavouriteButton() {
        self.view.addSubview(fovoriteButton)
        fovoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fovoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 10),
            fovoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -10),
            fovoriteButton.widthAnchor.constraint(equalToConstant: 24),
            fovoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func addProductTitleLabel() {
        self.view.addSubview(productTitleLabel)
        productTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productTitleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 16),
            productTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            productTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -36)
        ])
        productTitleLabel.setContentHuggingPriority(.required, for: .vertical)
        productTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
        
    private func addProductDescriptionLabel() {
        self.view.addSubview(productDescriptionLabel)
        productDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productDescriptionLabel.topAnchor.constraint(equalTo: productTitleLabel.bottomAnchor, constant: 0),
            productDescriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            productDescriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            productDescriptionLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
        
        productDescriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        productDescriptionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    private func addPriceStackView() {
        self.view.addSubview(priceStackView)
        priceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        priceStackView.addArrangedSubview(priceLabel)
        priceStackView.addArrangedSubview(priceValueLabel)
        
        NSLayoutConstraint.activate([
            priceStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            priceStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addAddToCartButton() {
        self.view.addSubview(addToCartButton)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addToCartButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            addToCartButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            addToCartButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.46),
            addToCartButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
}

// MARK: - Configure Contents
private extension ProductDetailViewController {
    
    private func configureContents() {
        configureBackButton()
        configureHeaderLabel()
        configureProductImageView()
        configureFavouriteButton()
        configureProductTitleLabel()
        configureProductDesriptionLabel()
        configurePriceStackView()
        configurePriceLabel()
        configurePriceValueLabel()
        configureAddToCartButton()
    }

    private func configureBackButton() {
        backButton.setImage(UIImage(named: "iconLeft"), for: .normal)
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func configureHeaderLabel() {
        headerLabel.text = viewModel.productName
        headerLabel.font = UIFont.montserratExtraBold(size: 24)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .left
    }
    
    private func configureProductImageView() {
        productImageView.backgroundColor = .productGray
        productImageView.contentMode = .scaleAspectFit
    }
    
    private func configureFavouriteButton() {
        fovoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        fovoriteButton.tintColor = .appGray
        fovoriteButton.backgroundColor = .clear
        fovoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func configureProductTitleLabel() {
        productTitleLabel.text = viewModel.productName ?? "Product Name"
        productTitleLabel.font = UIFont.montserratBold(size: 20)
        productTitleLabel.numberOfLines = 0
        productTitleLabel.textColor = .black
        productTitleLabel.textAlignment = .left
    }
    
    private func configureProductDesriptionLabel() {
        productDescriptionLabel.text = viewModel.productDescription
        productDescriptionLabel.font = UIFont.montserratRegular(size: 14)
        productDescriptionLabel.numberOfLines = 0
        productDescriptionLabel.textColor = .black
        productDescriptionLabel.textAlignment = .left
    }
    
    private func configurePriceLabel() {
        priceLabel.text = "Price:"
        priceLabel.font = UIFont.montserratRegular(size: 16)
        priceLabel.textColor = .appBlue
        priceLabel.textAlignment = .left
    }
    
    private func configurePriceStackView() {
        priceStackView.axis = .vertical
        priceStackView.spacing = 4
        priceStackView.alignment = .leading
        priceStackView.distribution = .fill
    }
    
    private func configurePriceValueLabel() {
        let price = viewModel.productPrice ?? "0"
          priceValueLabel.text = "\(price) ₺"
        priceValueLabel.font = UIFont.montserratBold(size: 20)
        priceValueLabel.textColor = .black
        priceValueLabel.textAlignment = .left
    }
    
    private func configureAddToCartButton() {
        addToCartButton.setTitle("Add to Cart", for: .normal)
        addToCartButton.titleLabel?.font = UIFont.montserratSemiBold(size: 16)
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.backgroundColor = .appBlue
        addToCartButton.layer.cornerRadius = 4
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteStatusChanged),
            name: .favoriteItemAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteStatusChanged),
            name: .favoriteItemRemoved,
            object: nil
        )
    }
}

// MARK: - Actions
private extension ProductDetailViewController {
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        viewModel.toggleFavorite()
    }
    
    @objc private func addToCartButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToCartButton.transform = CGAffineTransform.identity
            }
        }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        viewModel.addToCart()
      }
    
    @objc private func favoriteStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationProductId = userInfo["productId"] as? String,
              let currentProductId = viewModel.productId,
              notificationProductId == currentProductId else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.updateFavoriteButtonState()
        }
    }
    
    
    private func updateFavoriteButtonState() {
        let isFavorite = viewModel.isFavorite
        
        if isFavorite {
            fovoriteButton.tintColor = .systemYellow
            fovoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            fovoriteButton.tintColor = .appGray
            fovoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.fovoriteButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.fovoriteButton.transform = CGAffineTransform.identity
            }
        }
    }
}

// MARK: - ViewModel Subscription
private extension ProductDetailViewController {
    
    private func subscribeViewModel() {
        viewModel.addToCartSuccess = { [weak self] productName in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showAddToCartSuccess(in: self.view, productName: productName)
            }
        }
        
        viewModel.addToCartFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async  {
                ToastHelper.showError(in: self.view, message: errorMessage)
            }
        }
        
        viewModel.favoriteToggleSuccess = { [weak self] message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showSuccess(in: self.view, message: message)
            }
        }
        
        viewModel.favoriteToggleFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showError(in: self.view, message: errorMessage)
            }
        }
    }
}

