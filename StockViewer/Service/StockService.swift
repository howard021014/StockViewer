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
    let urlString = "https://6twxtqzjyoyruhqzywfrcdxoci0sltgk.lambda-url.us-east-1.on.aws/"
    var dataTask: URLSessionDataTask?
      
    func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 5
        return URLSession(configuration: configuration)
    }
    
    func fetchStocks(completion: @escaping StockCompletion) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = createSession()
        dataTask?.cancel()
        
        dataTask = session.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.dataTask = nil }
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    return
                }
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
        dataTask?.resume()
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
