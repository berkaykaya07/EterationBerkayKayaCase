//
//  FavoriteService.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

final class FavoriteService {
    
    // MARK: - Singleton
    static let shared = FavoriteService()
    private init() {}
    
    // MARK: - Dependencies
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Public Methods
    
    func addToFavorites(product: Product, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let productId = product.id,
              let productName = product.name else {
            let error = NSError(domain: "FavoriteService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Product information is incomplete"])
            completion?(.failure(error))
            return
        }
        
        guard !isProductInFavorites(productId: productId) else {
            completion?(.success(()))
            return
        }
        
        coreDataManager.addFavoriteItem(productId: productId, productName: productName)
        
        NotificationCenter.default.post(
            name: .favoriteItemAdded,
            object: nil,
            userInfo: [
                "product": product,
                "productId": productId
            ]
        )
        completion?(.success(()))
    }
    
    func removeFromFavorites(productId: String) {
        coreDataManager.deleteFavoriteItem(productId: productId)
        
        // Notification gönder
        NotificationCenter.default.post(
            name: .favoriteItemRemoved,
            object: nil,
            userInfo: ["productId": productId]
        )
    }
    
    func toggleFavorite(product: Product) {
        guard let productId = product.id else { return }
        
        if isProductInFavorites(productId: productId) {
            removeFromFavorites(productId: productId)
        } else {
            addToFavorites(product: product)
        }
    }
    
    func isProductInFavorites(productId: String) -> Bool {
        return coreDataManager.getFavoriteItem(by: productId) != nil
    }
    
    func getFavoriteItems() -> [FavoriteItem] {
        return coreDataManager.fetchFavoriteItems()
    }
    
    func getFavoriteCount() -> Int {
        return getFavoriteItems().count
    }
    
    func clearAllFavorites(completion: ((Result<Void, Error>) -> Void)? = nil) {
        let items = getFavoriteItems()
        for item in items {
            if let productId = item.productId {
                coreDataManager.deleteFavoriteItem(productId: productId)
            }
        }
        NotificationCenter.default.post(name: .allFavoritesCleared, object: nil)
        completion?(.success(()))
    }
}
