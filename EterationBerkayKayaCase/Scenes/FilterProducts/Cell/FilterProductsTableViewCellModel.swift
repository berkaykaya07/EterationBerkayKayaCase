//
//  FilterProductsTableViewCellModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation
import UIKit

protocol FilterProductsTableViewCellDataSource: AnyObject {
    var title: String? { get set }
    var isSelected: Bool { get set }
}

protocol FilterProductsTableViewCellEventSource: AnyObject { }

protocol FilterProductsTableViewCellProtocol: FilterProductsTableViewCellDataSource, FilterProductsTableViewCellEventSource { }

// MARK: - Model
final class FilterProductsTableViewCellModel: FilterProductsTableViewCellProtocol {
    
    public var title: String?
    public var isSelected: Bool
    
    public init(title: String?, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }
}

