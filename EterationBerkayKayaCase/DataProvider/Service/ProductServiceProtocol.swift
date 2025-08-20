//
//  ProductServiceProtocol.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

protocol ProductServiceProtocol {
    
    func getProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void)
}
