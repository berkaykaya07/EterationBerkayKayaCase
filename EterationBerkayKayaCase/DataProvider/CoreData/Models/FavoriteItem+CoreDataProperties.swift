//
//  FavoriteItem+CoreDataProperties.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import CoreData

extension FavoriteItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteItem> {
        return NSFetchRequest<FavoriteItem>(entityName: "FavoriteItem")
    }

    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var dateAdded: Date?
}

extension FavoriteItem : Identifiable {

}

