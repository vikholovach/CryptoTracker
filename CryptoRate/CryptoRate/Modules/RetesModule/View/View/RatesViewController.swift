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
    
    var presenter: CoinViewPresenterProtocol!
    private var previousPrice = 0.0
    
    //MARK: - Data source
    private var dataSource: UITableViewDiffableDataSource<Sections, CryptoData>?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchCoins()
    }
    
    //MARK: - Methods
    private func setupSearchBar() {
        let placeholder = "Search"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red // Your desired color
        ]
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
            if let leftView = textFieldInsideSearchBar.leftView as? UIImageView {
                leftView.tintColor = UIColor.blue // Your desired color
            }
        }
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
