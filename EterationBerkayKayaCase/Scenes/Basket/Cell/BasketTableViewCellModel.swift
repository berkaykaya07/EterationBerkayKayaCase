//
//  BasketTableViewCellModel.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

protocol BasketTableViewCellDataSource: AnyObject {
    var productName: String? { get }
    var quantity: Int { get }
    var totalPrice: String? { get }
    var productId: String { get }
}

protocol BasketTableViewCellEventSource: AnyObject {
    var quantityChanged: ((String, Int) -> Void)? { get set }
}

protocol BasketTableViewCellProtocol: BasketTableViewCellDataSource, BasketTableViewCellEventSource {}


final class BasketTableViewCellModel: BasketTableViewCellProtocol {
    
    // MARK: - DataSource Properties
    let productName: String?
    let totalPrice: String?
    let productId: String
    var quantity: Int
    var totalPriceValue: Double {
        return unitPrice * Double(quantity)
    }
    
    // MARK: - EventSource Properties
    var quantityChanged: ((String, Int) -> Void)?
    
    // MARK: - Private Properties
    private let unitPrice: Double

    init(productId: String, productName: String, price: String, quantity: Int) {
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        
        let cleanPriceString = price.replacingOccurrences(of: ",", with: "")
        self.unitPrice = Double(cleanPriceString) ?? 0.0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let totalPriceValue = unitPrice * Double(quantity)
        if let formattedPrice = formatter.string(from: NSNumber(value: totalPriceValue)) {
            self.totalPrice = "\(formattedPrice)₺"
        } else {
            self.totalPrice = "0₺"
        }
    }
    
    func updateQuantity(_ newQuantity: Int) {
        self.quantity = newQuantity
    }
}

