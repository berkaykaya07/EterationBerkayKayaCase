//
//  ProductsRepository.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

final class ProductsRepository: ProductsRepositoryProtocol {
    
    private var productService: ProductServiceProtocol
    
    //MARK: - Inject ProductServiceProtocol
    public init(productService : ProductServiceProtocol) {
        self.productService = productService
    }
    
    public func getProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        productService.getProducts { result in
            switch result {
            case .success(let getCategoriesResponse):
                return completion(.success(getCategoriesResponse))
            case .failure(let error):
               return  completion(.failure(error))
            }
        }
    }
}
