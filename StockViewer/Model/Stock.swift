//
//  Stock.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-14.
//

import Foundation

typealias Stocks = [String: StockData]
typealias Stock = (symbol: String, data: StockData)

struct StockData: Decodable {
    let name: String
    let price: Double
    let low: Double
    let high: Double
}


