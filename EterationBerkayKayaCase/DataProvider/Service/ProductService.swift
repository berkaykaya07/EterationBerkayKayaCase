//
//  ProductService.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

final class ProductService: ProductServiceProtocol {
    
    func getProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        NetworkExecuter.shared.execute(route: ProductsApiClient.products, responseModel: [Product].self, completion: completion)
    }
}

