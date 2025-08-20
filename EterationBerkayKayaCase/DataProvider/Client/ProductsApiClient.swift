//
//  ProductsApiClient.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

enum ProductsApiClient : BaseClientGenerator {
    
    // MARK: - Requests
    case products
    
    var scheme: String { "https" }
    
    var host: String { "5fc9346b2af77700165ae514.mockapi.io" }
    
    // MARK: - PATH
    var path: String {
        switch self {
        case .products:
            return "/products"
        }
    }
    
    //MARK: - Query Items
    var queryItems: [URLQueryItem]?{
        let items: [URLQueryItem] = []
        switch self {
        case .products:
            break
        }
        return items
    }
    
    //MARK: - Default GET
    var method: HttpMethod{
        switch self {
        default:
            return .get
        }
    }
    
    // MARK: - Header
    var header: [HttpHeader]? {
        return [
            .contentType(),
        ]
    }
    
    //MARK: - Default Nil
    var body: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
}
