//
//  BasketViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class BasketViewController: BaseViewController<BasketViewModel> {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let bottomContainerView = UIView()
    private let totalStackView = UIStackView()
    private let totalLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContents()
        subscribeViewModel()
        viewModel.didLoad()
    }
}

// MARK: - UILayout
private extension BasketViewController {
    
    private func setupUI() {
        addTitleLabel()
        addTableView()
        addBottomContainer()
        addEmptyStateView()
    }
    
    private func addTitleLabel() {
        let titleItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = titleItem
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }
    
    private func addBottomContainer() {
        view.addSubview(bottomContainerView)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(totalStackView)
        
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        totalStackView.addArrangedSubview(totalLabel)
        totalStackView.addArrangedSubview(totalAmountLabel)
        
        bottomContainerView.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            totalStackView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 0),
            totalStackView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            
            completeButton.centerYAnchor.constraint(equalTo: totalStackView.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor, multiplier: 0.46),
            completeButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    private func addEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
    }
}

// MARK: - Configure Contents
private extension BasketViewController {
    
    private func configureContents() {
        configureTitleLabel()
        configureNavigationBarAppearance()
        configureTableView()
        configureBottomContainerElements()
        configureEmptyState()
    }
    
    private func configureTitleLabel() {
        titleLabel.text = "E-Market"
        titleLabel.font = UIFont.montserratExtraBold(size: 24)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
    }
    
    private func configureNavigationBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .appBlue
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.montserratExtraBold(size: 24)
            ]
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
        navigationBar.barStyle = .black
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BasketTableViewCell.self, forCellReuseIdentifier: BasketTableViewCell.identifier)
    }
    
    private func configureBottomContainerElements() {
        totalStackView.axis = .vertical
        totalStackView.spacing = 2
        totalStackView.alignment = .leading
        
        totalLabel.text = "Total:"
        totalLabel.font = UIFont.montserratRegular(size: 18)
        totalLabel.textColor = .appBlue
        
        totalAmountLabel.font = UIFont.montserratBold(size: 20)
        totalAmountLabel.textColor = .black
        
        completeButton.setTitle("Complete", for: .normal)
        completeButton.titleLabel?.font = UIFont.montserratSemiBold(size: 16)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = .appBlue
        completeButton.layer.cornerRadius = 4
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    private func configureEmptyState() {
        emptyStateView.backgroundColor = .clear
        emptyStateView.isHidden = true
        
        emptyStateLabel.text = "Your basket is empty\nAdd some products to get started!"
        emptyStateLabel.font = UIFont.montserratMedium(size: 18)
        emptyStateLabel.textColor = .systemGray2
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
}

// MARK: - Actions
extension BasketViewController {
    
    @objc private func completeButtonTapped() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.completeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.completeButton.transform = CGAffineTransform.identity
            }
        }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        viewModel.completeOrder()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BasketTableViewCell.identifier,
            for: indexPath
        ) as? BasketTableViewCell else {
            fatalError("Could not dequeue BasketTableViewCell")
        }
        
        cell.set(viewModel: viewModel.cellForItemAt(indexPath: indexPath))
        return cell
    }
}

// MARK: - ViewModel Subscription
private extension BasketViewController {
    
    func subscribeViewModel() {
        viewModel.reloadData = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.deleteRow = { [weak self] indexPath in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: nil)
            }
        }
        
        viewModel.updateTotalAmount = { [weak self] amount in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.totalAmountLabel.text = amount
            }
        }
        
        viewModel.showEmptyState = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
                self.bottomContainerView.isHidden = true
            }
        }
        
        viewModel.hideEmptyState = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
                self.bottomContainerView.isHidden = false
            }
        }
        
        viewModel.orderCompletedSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showSuccess(in: self.view, message: "Order completed successfully! 🎉")
            }
        }
        
        viewModel.orderCompletedFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if errorMessage.contains("empty") {
                    ToastHelper.showWarning(in: self.view, message: errorMessage)
                } else {
                    ToastHelper.showError(in: self.view, message: "Failed to complete order: \(errorMessage)")
                }
            }
        }
    }
}
