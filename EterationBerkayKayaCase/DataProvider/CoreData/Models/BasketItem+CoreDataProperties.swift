//
//  BasketItem+CoreDataProperties.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import CoreData

extension BasketItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BasketItem> {
        return NSFetchRequest<BasketItem>(entityName: "BasketItem")
    }
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var price: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var dateAdded: Date?
}

extension BasketItem : Identifiable {

}

