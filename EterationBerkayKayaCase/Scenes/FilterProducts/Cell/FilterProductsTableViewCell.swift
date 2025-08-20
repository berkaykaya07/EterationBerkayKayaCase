//
//  FilterProductsTableViewCell.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class FilterProductsTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let checkBoxButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    var onToggleSelection: (() -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func set(viewModel: FilterProductsTableViewCellProtocol) {
        titleLabel.text = viewModel.title
        let imageName = viewModel.isSelected ? "squareFilled" : "squareEmpty"
        checkBoxButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

// MARK: - UILayout
private extension FilterProductsTableViewCell {
   
    private func setupUI() {
        selectionStyle = .none
        addCheckBoxButton()
        addTitleLabel()
    }
    
    private func addCheckBoxButton() {
        contentView.addSubview(checkBoxButton)
        checkBoxButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkBoxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkBoxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 16),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func addTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: 9),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}

// MARK: - Actions
private extension FilterProductsTableViewCell {
    
    @objc private func toggleSelection() {
        onToggleSelection?()
    }
}

// MARK: - Configure Components
private extension FilterProductsTableViewCell {
    
   private func configureContents() {
       configureCheckBox()
       configurTitleLabel()
    }
    
   private func configureCheckBox() {
       checkBoxButton.tintColor = .appBlue
       checkBoxButton.setImage(UIImage(named: "squareFilled"), for: .normal)
       checkBoxButton.addTarget(self, action: #selector(toggleSelection), for: .touchUpInside)
   }
    
    private func configurTitleLabel() {
        titleLabel.font = UIFont.montserratRegular(size: 14)
        titleLabel.textColor = .black
    }
}

