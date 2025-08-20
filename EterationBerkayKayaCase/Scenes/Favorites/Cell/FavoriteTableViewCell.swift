//
//  FavoriteTableViewCell.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class FavoriteTableViewCell: UITableViewCell {
    
    static let identifier = "FavoriteTableViewCell"
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let favoriteIconView = UIImageView()
    private let contentStackView = UIStackView()
    private let productNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let removeButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var viewModel: FavoriteTableViewCellProtocol?
    
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
    func set(viewModel: FavoriteTableViewCellProtocol) {
        self.viewModel = viewModel
        productNameLabel.text = viewModel.productName
        dateLabel.text = viewModel.formattedDate
    }
}

// MARK: - UILayout
private extension FavoriteTableViewCell {
    
    private func setupUI() {
        selectionStyle = .none
        addContainerView()
        addFavoriteIconView()
        addContentStackView()
        addRemoveButton()
    }
    
    private func addContainerView() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func addFavoriteIconView() {
        containerView.addSubview(favoriteIconView)
        favoriteIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            favoriteIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            favoriteIconView.widthAnchor.constraint(equalToConstant: 24),
            favoriteIconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func addContentStackView() {
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.alignment = .leading
        contentStackView.distribution = .fill
        
        contentStackView.addArrangedSubview(productNameLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: favoriteIconView.trailingAnchor, constant: 16),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func addRemoveButton() {
        containerView.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 80),
            removeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}

// MARK: - Configure Components
private extension FavoriteTableViewCell {
    
    private func configureContents() {
        configureContainerView()
        configureFavoriteIconView()
        configureProductNameLabel()
        configureDateLabel()
        configureRemoveButton()
    }
    
    private func configureContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
    }
    
    private func configureFavoriteIconView() {
        favoriteIconView.image = UIImage(systemName: "star.fill")
        favoriteIconView.tintColor = .systemYellow
        favoriteIconView.contentMode = .scaleAspectFit
    }
    
    private func configureProductNameLabel() {
        productNameLabel.font = UIFont.montserratMedium(size: 16)
        productNameLabel.textColor = .black
        productNameLabel.numberOfLines = 1
        productNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func configureDateLabel() {
        dateLabel.font = UIFont.montserratRegular(size: 12)
        dateLabel.textColor = .systemGray
        dateLabel.numberOfLines = 1
        dateLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func configureRemoveButton() {
        removeButton.setTitle("Remove", for: .normal)
        removeButton.titleLabel?.font = UIFont.montserratMedium(size: 14)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.backgroundColor = .systemRed
        removeButton.layer.cornerRadius = 6
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension FavoriteTableViewCell {

    @objc private func removeButtonTapped() {
        guard let viewModel = viewModel else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.removeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.removeButton.transform = CGAffineTransform.identity
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        viewModel.removeFromFavorites?(viewModel.productId)
    }
}
