//
//  BasketTableViewCell.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class BasketTableViewCell: UITableViewCell {
    
    static let identifier = "BasketTableViewCell"
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let productNameLabel = UILabel()
    private let productPriceLabel = UILabel()
    private let quantityStackView = UIStackView()
    private let decrementButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let incrementButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var viewModel: BasketTableViewCellProtocol?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    // MARK: - Public Methods
    func set(viewModel: BasketTableViewCellProtocol) {
        self.viewModel = viewModel
        productNameLabel.text = viewModel.productName
        productPriceLabel.text = viewModel.totalPrice
        quantityLabel.text = "\(viewModel.quantity)"
    }
}

// MARK: - UILayout
private extension BasketTableViewCell {
    
    private func setupUI() {
        selectionStyle = .none
        addContainerView()
        addQuantityStackView()
        addProductNameLabel()
        addProductPriceLabel()
    }
    
    private func addContainerView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func addProductNameLabel() {
        containerView.addSubview(productNameLabel)
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            productNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            productNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: quantityStackView.leadingAnchor, constant: -16)
        ])
    }
    
    private func addProductPriceLabel() {
        containerView.addSubview(productPriceLabel)
        productPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productPriceLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productPriceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            productPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func addQuantityStackView() {
        containerView.addSubview(quantityStackView)
        quantityStackView.translatesAutoresizingMaskIntoConstraints = false
        
        quantityStackView.axis = .horizontal
        quantityStackView.spacing = 0
        quantityStackView.alignment = .center
        quantityStackView.distribution = .fill
        
        quantityStackView.addArrangedSubview(decrementButton)
        quantityStackView.addArrangedSubview(quantityLabel)
        quantityStackView.addArrangedSubview(incrementButton)
        
        NSLayoutConstraint.activate([
            quantityStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            quantityStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            quantityStackView.heightAnchor.constraint(equalToConstant: 50),
            quantityStackView.widthAnchor.constraint(equalToConstant: 119),
            
            decrementButton.widthAnchor.constraint(equalToConstant: 38),
            decrementButton.heightAnchor.constraint(equalToConstant: 37),
            
            quantityLabel.widthAnchor.constraint(equalToConstant: 43),
            quantityLabel.heightAnchor.constraint(equalToConstant: 40),
            
            incrementButton.widthAnchor.constraint(equalToConstant: 38),
            incrementButton.heightAnchor.constraint(equalToConstant: 37)
        ])
    }
}

// MARK: - Configure Components
private extension BasketTableViewCell {
    
    private func configureContents() {
        configureProductNameLabel()
        configureProductPriceLabel()
        configureQuantityControls()
    }
    
    private func configureQuantityControls() {
        decrementButton.setTitle("−", for: .normal)
        decrementButton.titleLabel?.font = UIFont.montserratBold(size: 12)
        decrementButton.setTitleColor(.black, for: .normal)
        decrementButton.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        decrementButton.layer.cornerRadius = 4
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        
        quantityLabel.font = UIFont.montserratRegular(size: 18)
        quantityLabel.textColor = .white
        quantityLabel.textAlignment = .center
        quantityLabel.backgroundColor = .appBlue
        quantityLabel.clipsToBounds = true
        
        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleLabel?.font = UIFont.montserratBold(size: 12)
        incrementButton.setTitleColor(.black, for: .normal)
        incrementButton.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        incrementButton.layer.cornerRadius = 4
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
    }
    
    private func configureProductNameLabel() {
        productNameLabel.font = UIFont.montserratRegular(size: 16)
        productNameLabel.textColor = .black
        productNameLabel.numberOfLines = 1
    }
    
    private func configureProductPriceLabel() {
        productPriceLabel.font = UIFont.montserratMedium(size: 14)
        productPriceLabel.textColor = .appBlue
    }
}

// MARK: - Actions
private extension BasketTableViewCell {

    @objc private func decrementTapped() {
         guard let viewModel = viewModel else { return }
         let newQuantity = viewModel.quantity - 1
         if newQuantity <= 0 {
             viewModel.quantityChanged?(viewModel.productId, 0)
         } else {
             viewModel.quantityChanged?(viewModel.productId, newQuantity)
             quantityLabel.text = "\(newQuantity)"
         }
     }
    
    @objc private func incrementTapped() {
        guard let viewModel = viewModel else { return }
        let newQuantity = viewModel.quantity + 1
        viewModel.quantityChanged?(viewModel.productId, newQuantity)
        quantityLabel.text = "\(newQuantity)"
    }
}
