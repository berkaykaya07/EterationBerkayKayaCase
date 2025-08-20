//
//  ProductCollectionViewCellModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import UIKit

protocol ProductCollectionViewCellDataSource: AnyObject {
    var price: String? { get }
    var productName: String? { get }
}

protocol ProductCollectionViewCellEventSource: AnyObject {
    
}

protocol ProductCollectionViewCellProtocol: ProductCollectionViewCellDataSource, ProductCollectionViewCellEventSource {}

final class ProductCollectionViewCellModel: ProductCollectionViewCellProtocol {
    
    public var price: String?
    public var productName: String?
    
    public init(price: String?, productName: String?) {
        self.price = price
        self.productName = productName
    }
}

