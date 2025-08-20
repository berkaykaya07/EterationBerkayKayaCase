//
//  ProductDetailViewModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//


import UIKit

protocol ProductDetailDataSource {
    var productName: String? { get }
    var productPrice: String? { get }
    var productDescription: String? { get }
    var productId: String? { get }
    var isFavorite: Bool { get }
    
    func addToCart()
    func toggleFavorite()
}

protocol ProductDetailEventSource {
    var favoriteStatusChanged: BoolClosure? { get }
    var addToCartSuccess: StringClosure? { get }
    var addToCartFailure: StringClosure? { get }
    var favoriteToggleSuccess: StringClosure? { get }
    var favoriteToggleFailure: StringClosure? { get }
}

protocol ProductDetailProtocol: ProductDetailDataSource, ProductDetailEventSource {}

final class ProductDetailViewModel: BaseViewModel, ProductDetailProtocol {
    
    // MARK: - EventSource Properties
    var favoriteStatusChanged: ((Bool) -> Void)?
    var addToCartSuccess: StringClosure?
    var addToCartFailure: StringClosure?
    var favoriteToggleSuccess: StringClosure?
    var favoriteToggleFailure: StringClosure?
    
    // MARK: - DataSource Properties
    var productName: String? {
        return selectedProduct?.name
    }
    
    var productPrice: String? {
        return selectedProduct?.price
    }
    
    var productDescription: String? {
        return selectedProduct?.description
    }
    
    var productId: String? {
        return selectedProduct?.id
    }
    
    var isFavorite: Bool {
        guard let productId = selectedProduct?.id else { return false }
        return FavoriteService.shared.isProductInFavorites(productId: productId)
    }
    
    // MARK: - Private Properties
    private var selectedProduct: Product?
    
    // MARK: - Initialization
    init(product: Product) {
        super.init()
        self.selectedProduct = product
        self.setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    func toggleFavorite() {
        guard let product = selectedProduct,
              let productId = product.id else {
            favoriteToggleFailure?("Product information not available")
            return
        }
        
        let wasInFavorites = FavoriteService.shared.isProductInFavorites(productId: productId)
        FavoriteService.shared.toggleFavorite(product: product)
        
        let productName = product.name ?? "Product"
        let message = wasInFavorites ?
            "\(productName) removed from favorites" :
            "\(productName) added to favorites! ⭐"
        
        favoriteToggleSuccess?(message)
    }
    
    func addToCart() {
        guard let product = selectedProduct else {
            addToCartFailure?("Product information not available")
            return
        }
        
        BasketService.shared.addToBasket(product: product) { [weak self] result in
                switch result {
                case .success:
                    let productName = product.name ?? "Product"
                    self?.addToCartSuccess?(productName)
                    
                case .failure(let error):
                    self?.addToCartFailure?(error.localizedDescription)
                }
        }
    }
    
    // MARK: - Private Methods
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoriteStatusChange),
            name: .favoriteItemAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoriteStatusChange),
            name: .favoriteItemRemoved,
            object: nil
        )
    }
    
    @objc private func handleFavoriteStatusChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationProductId = userInfo["productId"] as? String,
              let currentProductId = productId,
              notificationProductId == currentProductId else {
            return
        }
        favoriteStatusChanged?(isFavorite)
    }
}
