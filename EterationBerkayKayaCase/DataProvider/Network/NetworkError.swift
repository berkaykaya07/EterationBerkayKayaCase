//
//  NetworkError.swift
//  EterationBerkayKayaCase
//
//  Created by Berkay on 20.08.2025.
//

import Foundation

enum NetworkError : Error, LocalizedError{
    case invalidURL
    case request(statusCode : Int,data : Data?)
    case badRequest
    case decodeError
    case noInternet
    case noResponse
    case responseConvert
    case noData
}
