//
//  ProductListingViewController.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import UIKit

final class ProductsListingViewController: BaseViewController<ProductsListingViewModel> {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let filterLabel = UILabel()
    private let selectFilterButton = UIButton(type: .system)
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
         let indicator = UIActivityIndicatorView(style: .medium)
         indicator.hidesWhenStopped = true
         return indicator
     }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
        return cv
    }()
    
    // MARK: - Empty State Components
    private lazy var emptyStateView: UIView = {
          let containerView = UIView()
          containerView.backgroundColor = .clear
          containerView.isHidden = true
          return containerView
    }()
      
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass.circle")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        )
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
      
    private lazy var emptyTitleLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont.montserratSemiBold(size: 18)
          label.textColor = .darkGray
          label.textAlignment = .center
          label.numberOfLines = 0
          return label
    }()
      
    private lazy var emptySubtitleLabel: UILabel = {
          let label = UILabel()
          label.font = UIFont.montserratRegular(size: 14)
          label.textColor = .gray
          label.textAlignment = .center
          label.numberOfLines = 0
          return label
      }()
    
    // MARK: - Search Properties
    private var searchWorkItem: DispatchWorkItem?
    private let searchDebounceDelay: TimeInterval = 0.5
    private let minimumSearchLength = 2
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContents()
        subscribeViewModel()
        viewModel.didLoad()
    }
    
    deinit {
        searchWorkItem?.cancel()
        searchWorkItem = nil
    }
}

// MARK: - UILayout
private extension ProductsListingViewController {
    
    private func setupUI() {
        addTitleLabel()
        addSeachBar()
        addFilterLabel()
        addSelectFilterButton()
        addCollectionView()
        addLoadingIndicator()
        addEmptyStateView()
     }
    
    private func addTitleLabel() {
        let titleItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItem = titleItem
    }
    
    private func addSeachBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 40)])
    }
    
    private func addFilterLabel() {
        view.addSubview(filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        filterLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18),
        filterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)])
    }
    
    private func addSelectFilterButton() {
        view.addSubview(selectFilterButton)
        selectFilterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectFilterButton.centerYAnchor.constraint(equalTo: filterLabel.centerYAnchor),
            selectFilterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectFilterButton.leadingAnchor.constraint(greaterThanOrEqualTo: filterLabel.trailingAnchor, constant: 16),
            selectFilterButton.heightAnchor.constraint(equalToConstant: 36),
            selectFilterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)])
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addEmptyStateView() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
        
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: collectionView.trailingAnchor, constant: -32),
            
            emptyImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 120),
            emptyImageView.heightAnchor.constraint(equalToConstant: 120),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 24),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 12),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptySubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
}

// MARK: - Configure Contents
private extension ProductsListingViewController {
    
    private func configureContents() {
        configureTitleLabel()
        configureNavigationBarAppearance()
        configureSearchBar()
        configureFilterLabel()
        configureSelectFilterButton()
    }
   
   private func configureTitleLabel() {
       titleLabel.text = "E-Market"
       titleLabel.font = UIFont.montserratExtraBold(size: 24)
       titleLabel.textColor = .white
       titleLabel.textAlignment = .left
   }
   
   func configureNavigationBarAppearance() {
       guard let navigationBar = navigationController?.navigationBar else { return }
       navigationController?.setNavigationBarHidden(false, animated: false)
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
   
   private func configureSearchBar() {
       searchBar.placeholder = "Search"
       searchBar.searchBarStyle = .minimal
       searchBar.backgroundColor = .clear
       searchBar.barTintColor = .clear
       searchBar.searchTextField.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.98)
       searchBar.searchTextField.layer.cornerRadius = 8
       searchBar.searchTextField.font = UIFont.montserratRegular(size: 16)
       searchBar.searchTextField.textColor = .lightGray
       
       if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
           searchTextField.leftView?.tintColor = .systemGray
       }
       searchBar.delegate = self
   }
   
   private func configureFilterLabel() {
       filterLabel.text = "Filters:"
       filterLabel.font = UIFont.montserratMedium(size: 18)
       filterLabel.textColor = .black
   }
   
   private func configureSelectFilterButton() {
       selectFilterButton.setTitle("Select Filter", for: .normal)
       selectFilterButton.titleLabel?.font = UIFont.montserratRegular(size: 14)
       selectFilterButton.setTitleColor(.darkGray, for: .normal)
       selectFilterButton.backgroundColor = .appGray
       selectFilterButton.addTarget(self, action: #selector(selectFilterTapped), for: .touchUpInside)
   }
}
// MARK: - Actions
private extension ProductsListingViewController {
    
    @objc private func selectFilterTapped() {
        let filterViewModel = FilterProductsViewModel()
        let (currentSort, currentBrands, currentModels) = viewModel.getCurrentFilterState()
        
        filterViewModel.setupFilterData(with: viewModel.getAllProducts(),
                                      currentSort: currentSort,
                                      currentBrands: currentBrands,
                                      currentModels: currentModels)
        
        filterViewModel.onFiltersApplied = { [weak self] sortType, selectedBrands, selectedModels in
            self?.viewModel.applyFilters(sortType: sortType,
                                       selectedBrands: selectedBrands,
                                       selectedModels: selectedModels)
            self?.searchBar.searchTextField.text = ""
            self?.dismiss(animated: true)
        }
        
        let filterVC = FilterProductsViewController(viewModel: filterViewModel)
        filterVC.modalPresentationStyle = .fullScreen
        present(filterVC, animated: true)
    }
    
    private func showEmptyState(with message: String) {
        let lines = message.components(separatedBy: "\n")
        
        if lines.count > 1 {
            emptyTitleLabel.text = lines[0]
            emptySubtitleLabel.text = lines.dropFirst().joined(separator: "\n")
        } else {
            emptyTitleLabel.text = message
            emptySubtitleLabel.text = nil
        }
        emptyStateView.isHidden = false
        emptyStateView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.emptyStateView.alpha = 1
        }
    }
    
    private func hideEmptyState() {
        UIView.animate(withDuration: 0.2) {
            self.emptyStateView.alpha = 0
        } completion: { _ in
            self.emptyStateView.isHidden = true
            self.emptyStateView.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProductsListingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: ProductCollectionViewCell.identifier,
              for: indexPath
          ) as? ProductCollectionViewCell else {
              fatalError("Could not dequeue ProductCollectionViewCell")
          }
          
          let product = viewModel.getProductAt(index: indexPath.row)
          cell.set(product: product)
          cell.delegate = self
          return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadMoreIfNeeded(currentIndex: viewModel.numberOfItems - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
          
//          guard indexPath.row < viewModel.numberOfItems else { return }
//          let selectedProduct = viewModel.getProductAt(index: indexPath.row)
//          let detailViewModel = ProductDetailViewModel(product: selectedProduct)
//          let detailVC = ProductDetailViewController(viewModel: detailViewModel)
//          
//          navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductsListingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 10 + 16 + 16
        let availableWidth = collectionView.frame.width - padding
        let cellWidth = availableWidth / 2
        let cellHeight: CGFloat = 302
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - UISearchBarDelegate
extension ProductsListingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
            viewModel.clearAllFiltersAndSearch()
            return
        }
        
        guard trimmedText.count >= minimumSearchLength else { return }
        searchWorkItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                self?.viewModel.searchProducts(with: trimmedText)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + searchDebounceDelay,
                                      execute: searchWorkItem!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !searchText.isEmpty {
            viewModel.searchProducts(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clearAllFiltersAndSearch()
     }
     
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchWorkItem?.cancel()
    }
}

// MARK: - ViewModel Subscription
private extension ProductsListingViewController {
    
    func subscribeViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.insertNewItems = { [weak self] indexPaths in
            DispatchQueue.main.async {
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.insertItems(at: indexPaths)
                }, completion: nil)
            }
        }
        
        viewModel.showLoadingMore = { [weak self] in
            DispatchQueue.main.async {
                self?.loadingIndicator.startAnimating()
            }
        }
        
        viewModel.hideLoadingMore = { [weak self] in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
        }
        
        viewModel.showError = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ToastHelper.showError(in: self.view, message: errorMessage)
            }
        }
        
        viewModel.showEmptyState = { [weak self] message in
            DispatchQueue.main.async {
                self?.showEmptyState(with: message)
            }
        }
        
        viewModel.hideEmptyState = { [weak self] in
            DispatchQueue.main.async {
                self?.hideEmptyState()
            }
        }
        
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

// MARK: - ProductCollectionViewCellDelegate
extension ProductsListingViewController: ProductCollectionViewCellDelegate {
    
    func productCellDidTapFavorite(_ cell: ProductCollectionViewCell, product: Product) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        viewModel.toggleFavorite(product: product)
    }
  
    func productCellDidTapAddToCart(_ cell: ProductCollectionViewCell, product: Product) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        viewModel.addToCart(product: product)
    }
}
