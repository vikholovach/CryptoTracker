//
//  RatesViewController.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 23.08.2023.
//

import UIKit
import Combine

class RatesViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    
    //MARK: - Data source
    private var dataSource: UITableViewDiffableDataSource<Sections, CryptoData>?
    
    private var coins = [CryptoData]()
    private var filteredCoins = [CryptoData]()
    
    var presenter: CoinViewPresenterProtocol!
        
    private var cancellables: Set<AnyCancellable> = []
    private var searchTextSubject = PassthroughSubject<String, Never>()
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setSearchBar()
        
        searchTextSubject
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.filteredItems = searchText.isEmpty
                ? self.items
                : self.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                self.reloadData(with: filteredItems)
            }
            .store(in: &cancellables)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchCoins()
    }
    
    //MARK: - Methods
    private func setSearchBar() {
        self.searchBar.setPlaceholder(with: "Search", and: UIColor(hex: "FCFCFD"))
        self.searchBar.delegate = self
    }
    
    private func setupTableView() {
        self.tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTableViewCell")
        initDataSource()
    }
    
    private func initDataSource() {
        self.dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, coin -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "CoinTableViewCell",
                    for: indexPath) as? CoinTableViewCell else {
                    fatalError()
                }
                cell.configure(with: coin)
                return cell
            })
    }
    
    private func reloadData(with coins: [CryptoData]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, CryptoData>()
        snapshot.appendSections([.crypto])
        snapshot.appendItems(coins)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

extension RatesViewController: CoinViewProtocol {
    func onContentUpdate(with coins: [CryptoData]) {
        self.coins = coins
        self.reloadData(with: coins)
    }
    
    func onError(with error: Error) {
        let alert = UIAlertController(
            title: error.localizedDescription,
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .cancel))
        self.present(alert, animated: true)
        
    }
}

extension RatesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchTextSubject.send("")
    }
}
