//
//  Notification+Extension.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//
import Foundation

extension Notification.Name {
    static let basketItemAdded = Notification.Name("basketItemAdded")
    static let basketItemRemoved = Notification.Name("basketItemRemoved")
    static let basketItemQuantityUpdated = Notification.Name("basketItemQuantityUpdated")
    static let basketDidUpdate = Notification.Name("basketDidUpdate")
    static let basketDidClear = Notification.Name("basketDidClear")
    static let favoriteItemAdded = Notification.Name("favoriteItemAdded")
    static let favoriteItemRemoved = Notification.Name("favoriteItemRemoved")
    static let allFavoritesCleared = Notification.Name("allFavoritesCleared")
}

