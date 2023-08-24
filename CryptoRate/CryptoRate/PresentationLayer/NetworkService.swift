//
//  NetworkService.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 23.08.2023.
//

import Foundation
import Combine

protocol NetworkServiceProtocol: AnyObject {
    func fetchPrice() async -> (Result<[CryptoData], Error>)
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    //url to get bitcoin price
    private let url = "https://api.coincap.io/v2/assets"
        
    func fetchPrice() async -> (Result<[CryptoData], Error>) {
        guard let url = URL(string: self.url) else {
            return .failure(NetworlErrors.badUrl)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let coin = try JSONDecoder().decode(CryptoModel.self, from: data)
            return .success(coin.data)
        }
        catch {
            return .failure(error)
        }
    }
    
   
    
}

enum NetworlErrors: String, Error {
    case badUrl = "Bad url"
}
