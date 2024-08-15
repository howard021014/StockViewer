//
//  StockListViewModel.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-14.
//

import Foundation

enum AppState {
    case initial
    case loading
    case success([Stock])
    case failure(String)
}

typealias StateDidChange = ((AppState) -> Void)

class StockViewModel {
    let stockService: StockService
    
    private(set) var state: AppState = .initial {
        didSet {
            notifyObservers()
        }
    }
    
    private var timer: Timer?
    var isFirstLoad = true
    
    var observers = [UUID: StateDidChange]()

    init(stockService: StockService = StockServiceImpl()) {
        self.stockService = stockService
    }
    
    func startFetchStocks() {
        fetchStocks()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.fetchStocks()
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchStocks() {
        if isFirstLoad {
            state = .loading
        }
        stockService.fetchStocks { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let stocks):
                self.isFirstLoad = false
                self.state = .success(transform(stocks: stocks))
            case .failure(let error):
                if (error as NSError).code == NSURLErrorTimedOut {
                    self.state = .failure("The request timed out due to internet issues.")
                } else {
                    self.state = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    private func transform(stocks: Stocks) -> [Stock] {
        return stocks.map { Stock($0.key, $0.value) }.sorted { $0.symbol < $1.symbol }
    }
    
    func addObserver(_ observer: @escaping StateDidChange) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }
    
    func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }
    
    func notifyObservers() {
        observers.values.forEach { $0(state) }
    }
    
    deinit {
        stopTimer()
    }
}
