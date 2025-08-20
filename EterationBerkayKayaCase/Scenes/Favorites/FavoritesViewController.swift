//
//  FavoritesViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class FavoritesViewController: BaseViewController<FavoritesViewModel> {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let bottomContainerView = UIView()
    private let clearAllButton = UIButton(type: .system)
    private let emptyStateView = UIView()
    private let emptyStateImageView = UIImageView()
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
private extension FavoritesViewController {
    
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }
    
    private func addBottomContainer() {
        view.addSubview(bottomContainerView)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomContainerView.addSubview(clearAllButton)
        clearAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            clearAllButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            clearAllButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            clearAllButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            clearAllButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            clearAllButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func addEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 24),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
}

// MARK: - Configure Contents
private extension FavoritesViewController {
    
    private func configureContents() {
        configureTitleLabel()
        configureNavigationBarAppearance()
        configureTableView()
        configureClearAllButton()
        configureEmptyState()
    }
    
    private func configureTitleLabel() {
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
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.identifier)
    }
    
    private func configureClearAllButton() {
        clearAllButton.setTitle("Clear All Favorites", for: .normal)
        clearAllButton.titleLabel?.font = UIFont.montserratSemiBold(size: 16)
        clearAllButton.setTitleColor(.white, for: .normal)
        clearAllButton.backgroundColor = .systemRed
        clearAllButton.layer.cornerRadius = 8
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped), for: .touchUpInside)
    }
    
    private func configureEmptyState() {
        emptyStateView.backgroundColor = .clear
        emptyStateView.isHidden = true
        
        emptyStateImageView.image = UIImage(systemName: "star.circle")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        )
        emptyStateImageView.tintColor = .lightGray
        emptyStateImageView.contentMode = .scaleAspectFit
        
        emptyStateLabel.text = "Your favorites list is empty\nStart adding products you love!"
        emptyStateLabel.font = UIFont.montserratMedium(size: 18)
        emptyStateLabel.textColor = .systemGray2
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
}

// MARK: - Actions
extension FavoritesViewController {
    
    @objc private func clearAllButtonTapped() {
        let alert = UIAlertController(
            title: "Clear All Favorites",
            message: "Are you sure you want to remove all items from your favorites?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.performClearAll()
        })
        
        present(alert, animated: true)
    }
    
    private func performClearAll() {
        UIView.animate(withDuration: 0.1, animations: {
            self.clearAllButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.clearAllButton.transform = CGAffineTransform.identity
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        viewModel.clearAllFavorites()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteTableViewCell.identifier,
            for: indexPath
        ) as? FavoriteTableViewCell else {
            fatalError("Could not dequeue FavoriteTableViewCell")
        }
        
        cell.set(viewModel: viewModel.cellForItemAt(indexPath: indexPath))
        return cell
    }
}

// MARK: - ViewModel Subscription
private extension FavoritesViewController {
    
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
        
        viewModel.showEmptyState = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.emptyStateView.isHidden = false
                self.tableView.isHidden = true
                self.bottomContainerView.isHidden = true
                
                self.emptyStateView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.emptyStateView.alpha = 1
                }
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
        
        viewModel.favoriteRemovedSuccess = { [weak self] message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showSuccess(in: self.view, message: message)
            }
        }
        
        viewModel.favoriteRemovedFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showError(in: self.view, message: errorMessage)
            }
        }
        
        viewModel.allFavoritesClearedSuccess = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showSuccess(in: self.view, message: "All favorites cleared successfully!")
            }
        }
        
        viewModel.allFavoritesClearedFailure = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if errorMessage.contains("empty") {
                    ToastHelper.showWarning(in: self.view, message: errorMessage)
                } else {
                    ToastHelper.showError(in: self.view, message: "Failed to clear favorites: \(errorMessage)")
                }
            }
        }
    }
}
