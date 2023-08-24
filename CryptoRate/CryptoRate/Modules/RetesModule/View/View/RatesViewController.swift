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
    
    //Combine props
    private var cancellables: Set<AnyCancellable> = []
    var searchTextSubject = PassthroughSubject<String, Never>()
    
    //presenter
    var presenter: CoinViewPresenterProtocol!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setSearchBar()
        setupSearchPublisher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchCoins()
    }
    
    //MARK: - Methods
    private func setupSearchPublisher() {
        searchTextSubject
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                //if filtered array isEmpty -> we will show updated coins
                self.filteredCoins = searchText.isEmpty
                ? self.coins
                : self.coins.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                self.reloadData(with: filteredCoins)
            }
            .store(in: &cancellables)
    }
    
    private func setSearchBar() {
        self.searchBar.setPlaceholder(with: "Search", and: UIColor(hex: "FCFCFD"))
        self.searchBar.delegate = self
        self.searchBar.searchTextField.clearButtonMode = .never
    }
    
    private func setupTableView() {
        self.tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "CoinTableViewCell")
        self.tableView.keyboardDismissMode = .onDrag
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
    
    //in case of error while retrieving data -> show allert
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

