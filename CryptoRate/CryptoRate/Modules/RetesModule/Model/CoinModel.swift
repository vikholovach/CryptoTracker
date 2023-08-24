//
//  CoinModel.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 23.08.2023.
//

import Foundation

struct CryptoModel: Codable, Equatable, Hashable {
    let data: [CryptoData]
}

struct CryptoData: Codable, Equatable, Hashable {
    let symbol: String
    let name: String
    let priceUsd: String
    let changePercent24Hr: String
}

//MARK: - for Diffable data source
enum Sections {
    case crypto
}
