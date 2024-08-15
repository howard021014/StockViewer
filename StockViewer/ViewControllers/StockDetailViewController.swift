//
//  StockDetailViewController.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-14.
//

import UIKit

class StockDetailViewController: UITableViewController {

    let headings = ["Symbol", "Name", "Current Price", "Daily Low", "Daily High"]
    let viewModel: StockViewModel
    
    var stockInfo = [String]()
    var observerId: UUID?
    var stock: Stock

    init(viewModel: StockViewModel, stock: Stock) {
        self.viewModel = viewModel
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        
        generateStockInformation()
        setupTableView()
        setupViewModelBinding()
    }

    private func setupTableView() {
        tableView.register(StockDetailCell.self, forCellReuseIdentifier: StockDetailCell.identifier)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    private func setupViewModelBinding() {
        observerId = viewModel.addObserver { [weak self] appState in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch appState {
                case .initial, .loading:
                    break
                case .success(let stocks):
                    if let updatedStock = stocks.first(where: { $0.symbol == self.stock.symbol }) {
                        self.stock = updatedStock
                        self.generateStockInformation()
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    self.presentErrorAlert(with: error)
                }
            }
        }
    }
    
    private func generateStockInformation() {
        stockInfo = [stock.symbol, 
                     stock.data.name,
                     String(format: "$%.2f", stock.data.price),
                     String(format: "$%.2f", stock.data.low),
                     String(format: "$%.2f", stock.data.high)]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headings.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: StockDetailCell.identifier, for: indexPath) as? StockDetailCell {
            cell.configure(with: headings[indexPath.row], and: stockInfo[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    deinit {
        if let observerId = observerId {
            viewModel.removeObserver(observerId)
        }
    }
}
