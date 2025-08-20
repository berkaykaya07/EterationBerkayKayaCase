//
//  CoreDataManager.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Operations
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Basket Operations
    func fetchBasketItems() -> [BasketItem] {
        let request: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching basket items: \(error)")
            return []
        }
    }
    
    func addBasketItem(productId: String, productName: String, price: String, quantity: Int32) {
        let basketItem = BasketItem(context: context)
        basketItem.productId = productId
        basketItem.productName = productName
        basketItem.price = price
        basketItem.quantity = quantity
        basketItem.dateAdded = Date()
        
        saveContext()
    }
    
    func updateBasketItemQuantity(productId: String, newQuantity: Int32) {
        let request: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(request)
            if let item = items.first {
                item.quantity = newQuantity
                saveContext()
            }
        } catch {
            print("Error updating basket item: \(error)")
        }
    }
    
    func deleteBasketItem(productId: String) {
        let request: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(request)
            if let item = items.first {
                context.delete(item)
                saveContext()
            }
        } catch {
            print("Error deleting basket item: \(error)")
        }
    }
    
    func getBasketItem(by productId: String) -> BasketItem? {
        let request: NSFetchRequest<BasketItem> = BasketItem.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(request)
            return items.first
        } catch {
            print("Error fetching basket item: \(error)")
            return nil
        }
    }
    
    func fetchFavoriteItems() -> [FavoriteItem] {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorite items: \(error)")
            return []
        }
    }

    func addFavoriteItem(productId: String, productName: String) {
        let favoriteItem = FavoriteItem(context: context)
        favoriteItem.productId = productId
        favoriteItem.productName = productName
        favoriteItem.dateAdded = Date()
        
        saveContext()
    }
    
    func deleteFavoriteItem(productId: String) {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(request)
            if let item = items.first {
                context.delete(item)
                saveContext()
            }
        } catch {
            print("Error deleting favorite item: \(error)")
        }
    }
    
    func getFavoriteItem(by productId: String) -> FavoriteItem? {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        request.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(request)
            return items.first
        } catch {
            print("Error fetching favorite item: \(error)")
            return nil
        }
    }
}

