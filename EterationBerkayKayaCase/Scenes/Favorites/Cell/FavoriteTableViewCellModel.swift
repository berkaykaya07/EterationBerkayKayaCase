//
//  FavoriteTableViewCell.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol FavoriteTableViewCellDataSource: AnyObject {
    var productName: String? { get }
    var productId: String { get }
    var formattedDate: String { get }
}

protocol FavoriteTableViewCellEventSource: AnyObject {
    var removeFromFavorites: ((String) -> Void)? { get set }
}

protocol FavoriteTableViewCellProtocol: FavoriteTableViewCellDataSource, FavoriteTableViewCellEventSource {}

final class FavoriteTableViewCellModel: FavoriteTableViewCellProtocol {
    
    // MARK: - DataSource Properties
    let productName: String?
    let productId: String
    let formattedDate: String
    
    // MARK: - EventSource Properties
    var removeFromFavorites: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let dateAdded: Date?

    init(productId: String, productName: String, dateAdded: Date?) {
        self.productId = productId
        self.productName = productName
        self.dateAdded = dateAdded
        
        if let date = dateAdded {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            self.formattedDate = "Added: \(formatter.string(from: date))"
        } else {
            self.formattedDate = "Recently added"
        }
    }
}
