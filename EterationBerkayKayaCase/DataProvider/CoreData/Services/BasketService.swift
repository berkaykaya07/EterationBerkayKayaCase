//
//  BasketService.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

final class BasketService {
    
    // MARK: - Singleton
    static let shared = BasketService()
    private init() {}
    
    // MARK: - Dependencies
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Performance Cache
    private var cachedBasketItems: [BasketItem]?
    private var lastCacheUpdate: Date?
    private let cacheValidityDuration: TimeInterval = 0.5
    
    // MARK: - Public Methods
    func addToBasket(product: Product, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let productId = product.id,
              let productName = product.name,
              let price = product.price else {
            let error = NSError(domain: "BasketService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Product information is incomplete"])
            completion?(.failure(error))
            return
        }
        
        if let existingItem = coreDataManager.getBasketItem(by: productId) {
            let newQuantity = existingItem.quantity + 1
            updateQuantity(productId: productId, newQuantity: Int(newQuantity))
            completion?(.success(()))
        } else {
            coreDataManager.addBasketItem(
                productId: productId,
                productName: productName,
                price: price,
                quantity: 1
            )
            
            invalidateCache()
            
            NotificationCenter.default.post(
                name: .basketItemAdded,
                object: nil,
                userInfo: [
                    "product": product,
                    "quantity": 1
                ]
            )
            completion?(.success(()))
        }
        postBasketUpdateNotification()
    }
    
    func updateQuantity(productId: String, newQuantity: Int) {
        if newQuantity <= 0 {
            removeFromBasket(productId: productId)
        } else {
            coreDataManager.updateBasketItemQuantity(
                productId: productId,
                newQuantity: Int32(newQuantity)
            )
            invalidateCache()
            NotificationCenter.default.post(
                name: .basketItemQuantityUpdated,
                object: nil,
                userInfo: [
                    "productId": productId,
                    "newQuantity": newQuantity
                ]
            )
            postBasketUpdateNotification()
        }
    }
    
    func removeFromBasket(productId: String) {
        coreDataManager.deleteBasketItem(productId: productId)
        invalidateCache()
        
        NotificationCenter.default.post(
            name: .basketItemRemoved,
            object: nil,
            userInfo: ["productId": productId]
        )
        postBasketUpdateNotification()
    }
    
    func getBasketItems() -> [BasketItem] {
        if let cached = getCachedItems() {
            return cached
        }
        
        let items = coreDataManager.fetchBasketItems()
        updateCache(with: items)
        return items
    }
    
    func clearBasket(completion: ((Result<Void, Error>) -> Void)? = nil) {
        let items = getBasketItems()
        for item in items {
            if let productId = item.productId {
                coreDataManager.deleteBasketItem(productId: productId)
            }
        }
        invalidateCache()
        NotificationCenter.default.post(name: .basketDidClear, object: nil)
        postBasketUpdateNotification()
        completion?(.success(()))
    }
    
    func getTotalItemCount() -> Int {
        let items = getBasketItems()
        return items.reduce(0) { $0 + Int($1.quantity) }
    }
    
    func getTotalAmount() -> Double {
        let items = getBasketItems()
        return items.reduce(0.0) { result, item in
            guard let priceString = item.price,
                  let price = Double(priceString.replacingOccurrences(of: ",", with: "")) else {
                return result
            }
            return result + (price * Double(item.quantity))
        }
    }
    
    func getFormattedTotalAmount() -> String {
        let total = getTotalAmount()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        if let formattedAmount = formatter.string(from: NSNumber(value: total)) {
            return "\(formattedAmount)₺"
        }
        return "0₺"
    }
    
    func isProductInBasket(productId: String) -> Bool {
        return coreDataManager.getBasketItem(by: productId) != nil
    }
    
    func getProductQuantityInBasket(productId: String) -> Int {
        guard let item = coreDataManager.getBasketItem(by: productId) else {
            return 0
        }
        return Int(item.quantity)
    }
}

// MARK: - Performance Cache Management
private extension BasketService {
    
    func getCachedItems() -> [BasketItem]? {
        guard let cached = cachedBasketItems,
              let lastUpdate = lastCacheUpdate,
              Date().timeIntervalSince(lastUpdate) < cacheValidityDuration else {
            return nil
        }
        return cached
    }
    
    func updateCache(with items: [BasketItem]) {
        cachedBasketItems = items
        lastCacheUpdate = Date()
    }
    
    func invalidateCache() {
        cachedBasketItems = nil
        lastCacheUpdate = nil
    }
}

// MARK: - Notification
private extension BasketService {
    
    func postBasketUpdateNotification() {
        let items = getBasketItems()
        
        var totalItems = 0
        var totalAmount = 0.0
        
        for item in items {
            totalItems += Int(item.quantity)
            
            if let priceString = item.price,
               let price = Double(priceString.replacingOccurrences(of: ",", with: "")) {
                totalAmount += (price * Double(item.quantity))
            }
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let formattedAmount = formatter.string(from: NSNumber(value: totalAmount)) ?? "0"
        
        NotificationCenter.default.post(
            name: .basketDidUpdate,
            object: nil,
            userInfo: [
                "totalItems": totalItems,
                "totalAmount": "\(formattedAmount)₺"
            ]
        )
    }
}
