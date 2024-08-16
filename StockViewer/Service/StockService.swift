//
//  StockService.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-14.
//

import Foundation

typealias StockCompletion = ((Result<Stocks, Error>) -> Void)

protocol StockService {
    func fetchStocks(completion: @escaping StockCompletion)
}

class StockServiceImpl: StockService {
    private let urlString = "https://6twxtqzjyoyruhqzywfrcdxoci0sltgk.lambda-url.us-east-1.on.aws/"
    private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 15
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration)
    }()

    private var isRequestInProgress = false

    func fetchStocks(completion: @escaping StockCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        guard !isRequestInProgress else {
            return
        }

        isRequestInProgress = true

        let dataTask = session.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.isRequestInProgress = false }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let stocks = try JSONDecoder().decode(Stocks.self, from: data)
                completion(.success(stocks))
            } catch {
                completion(.failure(error))
            }
        }

        dataTask.resume()
    }
}

enum NetworkError: Error {
    case noData

    var localizedDescription: String {
        switch self {
        case .noData:
            return "No data returned from the server."
        }
    }
}
