//
//  Product.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

struct Product: Decodable {
    
    let createdAt: String?
    let name: String?
    let image: String?
    let price: String?
    let description: String?
    let model: String?
    let brand: String?
    let id: String?
     
    enum CodingKeys: String, CodingKey {
        case createdAt
        case name
        case image
        case price
        case description
        case model
        case brand
        case id
    }
}
