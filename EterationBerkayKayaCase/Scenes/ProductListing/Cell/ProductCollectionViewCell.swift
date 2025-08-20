//
//  ProductCollectionViewCell.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

// MARK: - Delegate Protocol
protocol ProductCollectionViewCellDelegate: AnyObject {
    func productCellDidTapAddToCart(_ cell: ProductCollectionViewCell, product: Product)
    func productCellDidTapFavorite(_ cell: ProductCollectionViewCell, product: Product)
}

final class ProductCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ProductCollectionViewCell"
    
    // MARK: - Properties
    weak var viewModel: ProductCollectionViewCellProtocol?
    weak var delegate: ProductCollectionViewCellDelegate?
    private var product: Product?
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let productImageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
    private let contentStackView = UIStackView()
    private let textStackView = UIStackView()
    private let priceLabel = UILabel()
    private let productNameLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureContents()
        setupNotificationObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        delegate = nil
        product = nil
        priceLabel.text = nil
        productNameLabel.text = nil
        updateFavoriteButtonState(isFavorite: false)
    }
    
    // MARK: - Public Methods
    func set(product: Product) {
        self.product = product
        priceLabel.text = "\(product.price ?? "") ₺"
        productNameLabel.text = product.name
        
        if let productId = product.id {
            let isFavorite = FavoriteService.shared.isProductInFavorites(productId: productId)
            updateFavoriteButtonState(isFavorite: isFavorite)
        }
    }
}

// MARK: - UILayout
private extension ProductCollectionViewCell {
    
    private func setupUI() {
        addContainerView()
        addProductImageView()
        addFavouriteButton()
        addContentStackView()
        addContentStackViewElements()
        addTextStackViewElements()
    }
    
    private func addContainerView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func addProductImageView() {
        containerView.addSubview(productImageView)
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            productImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            productImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func addFavouriteButton() {
        containerView.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 6),
            favoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -6),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func addContentStackView() {
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 15),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func addContentStackViewElements() {
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(addToCartButton)
        
        NSLayoutConstraint.activate([
            addToCartButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addTextStackViewElements() {
        textStackView.addArrangedSubview(priceLabel)
        textStackView.addArrangedSubview(productNameLabel)
    }
}

// MARK: - Configure Contents
private extension ProductCollectionViewCell {
    
    private func configureContents() {
        configureContainerView()
        configureProductImageView()
        configureFavouriteButton()
        configureContentStackView()
        configureTextStackView()
        configurePriceLabel()
        configureProductNameLabel()
        configureCartButton()
    }
    
    private func configureContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
    }
    
    private func configureProductImageView() {
        productImageView.backgroundColor = .productGray
        productImageView.contentMode = .scaleAspectFit
    }
    
    private func configureFavouriteButton() {
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .appGray
        favoriteButton.backgroundColor = .clear
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func configureContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .fill
        contentStackView.spacing = 15
    }
    
    private func configureTextStackView() {
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.alignment = .fill
        textStackView.spacing = 15
    }
    
    private func configurePriceLabel() {
        priceLabel.font = UIFont.montserratMedium(size: 14)
        priceLabel.textColor = .appBlue
        priceLabel.textAlignment = .left
        priceLabel.numberOfLines = 1
        priceLabel.setContentHuggingPriority(.required, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func configureProductNameLabel() {
        productNameLabel.font = UIFont.montserratMedium(size: 14)
        productNameLabel.textColor = .black
        productNameLabel.numberOfLines = 2
        productNameLabel.minimumScaleFactor = 0.5
        productNameLabel.adjustsFontSizeToFitWidth = true
        productNameLabel.textAlignment = .left
        productNameLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        productNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    private func configureCartButton() {
        addToCartButton.setTitle("Add to Cart", for: .normal)
        addToCartButton.titleLabel?.font = UIFont.montserratRegular(size: 16)
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.backgroundColor = .appBlue
        addToCartButton.layer.cornerRadius = 4
        addToCartButton.setContentHuggingPriority(.required, for: .vertical)
        addToCartButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Setup Notification
private extension ProductCollectionViewCell {
   
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
    
    @objc private func favoriteStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationProductId = userInfo["productId"] as? String,
              let currentProductId = product?.id,
              notificationProductId == currentProductId else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let productId = self.product?.id else { return }
            let isFavorite = FavoriteService.shared.isProductInFavorites(productId: productId)
            self.updateFavoriteButtonState(isFavorite: isFavorite)
        }
    }
    
    private func updateFavoriteButtonState(isFavorite: Bool) {
        if isFavorite {
            favoriteButton.tintColor = .systemYellow
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.tintColor = .appGray
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = CGAffineTransform.identity
            }
        }
    }
}


// MARK: - Actions
private extension ProductCollectionViewCell {
    
    @objc private func favoriteButtonTapped() {
        guard let product = product else {
            print("Product is nil, cannot toggle favorite")
            return
        }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        delegate?.productCellDidTapFavorite(self, product: product)
    }
    
    @objc private func addToCartButtonTapped() {
        guard let product = product else {
            print("Product is nil, cannot add to cart")
            return
        }
        delegate?.productCellDidTapAddToCart(self, product: product)
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToCartButton.transform = CGAffineTransform.identity
            }
        }
    }
}

