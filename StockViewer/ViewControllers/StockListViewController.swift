//
//  ViewController.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-14.
//

import UIKit

class StockListViewController: UITableViewController {

    let viewModel: StockViewModel
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let errorView = ErrorView()

    var stocks = [Stock]()
    var observerId: UUID?
    
    init(viewModel: StockViewModel = StockViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Popular stocks"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadingIndicator.hidesWhenStopped = true

        setupTableView()
        setupViewModelBinding()
        setupErrorView()
        viewModel.startFetchStocks()
    }
    
    private func setupErrorView() {
        errorView.frame = tableView.bounds
    }

    private func setupTableView() {
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.identifier)
        tableView.separatorStyle = .none
    }
    
    private func setupViewModelBinding() {
        observerId = viewModel.addObserver { [weak self] appState in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleStateChange(appState)
            }
        }
    }

    private func handleStateChange(_ appState: AppState) {
        switch appState {
        case .initial:
            break
        case .loading:
            self.showLoading()
        case .success(let stocks):
            self.stocks = stocks
            self.hideLoading()
            self.tableView.reloadData()
        case .failure(let error):
            if !self.viewModel.isFirstLoad {
                // To prevent both the detail and table view trying to present error
                // as both detail and table view are observing the state change
                if self.navigationController?.viewControllers.count == 1 {
                    self.presentErrorAlert(with: error)
                }
            } else {
                self.showErrorView()
            }
        }
    }
    
    private func showErrorView() {
        tableView.backgroundView = errorView
    }
    
    private func showLoading() {
        tableView.backgroundView = loadingIndicator
        loadingIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }

    deinit {
        if let observerId = observerId {
            viewModel.removeObserver(observerId)
        }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath) as? StockCell {
            cell.configure(with: stocks[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
        
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = StockDetailViewController(viewModel: viewModel, stock: stocks[indexPath.row])
        let backItem = UIBarButtonItem()
        backItem.title = stocks[indexPath.row].symbol
        navigationItem.backBarButtonItem = backItem
        show(vc, sender: self)
    }
}
