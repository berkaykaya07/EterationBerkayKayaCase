//
//  FavoritesViewModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol FavoritesDataSource {
    var numberOfItems: Int { get }
    
    func didLoad()
    func cellForItemAt(indexPath: IndexPath) -> FavoriteTableViewCellProtocol
    func removeFromFavorites(productId: String)
    func clearAllFavorites()
}

protocol FavoritesEventSource {
    var reloadData: VoidClosure? { get }
    var deleteRow: ((IndexPath) -> Void)? { get }
    var showEmptyState: VoidClosure? { get }
    var hideEmptyState: VoidClosure? { get }
    var favoriteRemovedSuccess: StringClosure? { get }
    var favoriteRemovedFailure: StringClosure? { get }
    var allFavoritesClearedSuccess: VoidClosure? { get }
    var allFavoritesClearedFailure: StringClosure? { get }
}

protocol FavoritesProtocol: FavoritesDataSource, FavoritesEventSource {}

class FavoritesViewModel: BaseViewModel, FavoritesProtocol {
    
    // MARK: - EventSource Properties
    var reloadData: VoidClosure?
    var deleteRow: ((IndexPath) -> Void)?
    var showEmptyState: VoidClosure?
    var hideEmptyState: VoidClosure?
    var favoriteRemovedSuccess: StringClosure?
    var favoriteRemovedFailure: StringClosure?
    var allFavoritesClearedSuccess: VoidClosure?
    var allFavoritesClearedFailure: StringClosure?

    // MARK: - DataSource Properties
    var numberOfItems: Int {
        return cellModels.count
    }
    
    func cellForItemAt(indexPath: IndexPath) -> FavoriteTableViewCellProtocol {
        guard indexPath.row >= 0 && indexPath.row < cellModels.count else {
            print("⚠️ Warning: Index out of bounds in FavoritesViewModel - row: \(indexPath.row), count: \(cellModels.count)")
            // Return empty cell model as fallback
            let fallbackModel = FavoriteTableViewCellModel(
                productId: "unknown",
                productName: "Unknown Product",
                dateAdded: Date()
            )
            return fallbackModel
        }
        return cellModels[indexPath.row]
    }
    
    // MARK: - Private Properties
    private var isEmptyState: Bool {
        return cellModels.isEmpty
    }
    private var cellModels: [FavoriteTableViewCellModel] = []
    private let favoriteService = FavoriteService.shared
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupNotificationObservers()
        loadFavoriteItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    func didLoad() {
        loadFavoriteItems()
        updateUI()
    }

    func removeFromFavorites(productId: String) {
        favoriteService.removeFromFavorites(productId: productId)
    }
    
    func clearAllFavorites() {
        guard !isEmptyState else {
            allFavoritesClearedFailure?("Your favorites list is already empty!")
            return
        }
        
        favoriteService.clearAllFavorites { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.allFavoritesClearedSuccess?()
            case .failure(let error):
                self.allFavoritesClearedFailure?(error.localizedDescription)
            }
        }
    }

    
    // MARK: - Private Methods
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteItemAdded),
            name: .favoriteItemAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteItemRemoved),
            name: .favoriteItemRemoved,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(allFavoritesCleared),
            name: .allFavoritesCleared,
            object: nil
        )
    }
    
    private func loadFavoriteItems() {
        let favoriteItems = favoriteService.getFavoriteItems()
        
        cellModels = favoriteItems.compactMap { favoriteItem in
            guard let productId = favoriteItem.productId,
                  let productName = favoriteItem.productName else {
                return nil
            }
            
            let cellModel = FavoriteTableViewCellModel(
                productId: productId,
                productName: productName,
                dateAdded: favoriteItem.dateAdded
            )
            
            cellModel.removeFromFavorites = { [weak self] productId in
                self?.removeFromFavorites(productId: productId)
            }
            return cellModel
        }
    }
    
    private func updateUI() {
        if self.isEmptyState {
            self.showEmptyState?()
        } else {
            self.hideEmptyState?()
        }
        self.reloadData?()
    }
    
    private func findCellModelIndex(by productId: String) -> Int? {
        return cellModels.firstIndex { $0.productId == productId }
    }
}

// MARK: - Notification Handlers
private extension FavoritesViewModel {
    
    @objc private func favoriteItemAdded(_ notification: Notification) {
        loadFavoriteItems()
        updateUI()
    }
    
    @objc private func favoriteItemRemoved(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let productId = userInfo["productId"] as? String,
              let index = findCellModelIndex(by: productId) else {
            loadFavoriteItems()
            updateUI()
            return
        }
        
        let removedProduct = cellModels[index]
        cellModels.remove(at: index)
        self.deleteRow?(IndexPath(row: index, section: 0))
        
        let productName = removedProduct.productName ?? "Product"
        self.favoriteRemovedSuccess?("\(productName) removed from favorites")
        
        if self.isEmptyState {
            self.showEmptyState?()
        }
    }
    
    @objc private func allFavoritesCleared(_ notification: Notification) {
        cellModels.removeAll()
        updateUI()
    }
}
