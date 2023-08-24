//
//  RatesViewController+UISearchBarExtension.swift
//  CryptoRate
//
//  Created by Viktor Golovach on 24.08.2023.
//

import UIKit
import Combine

extension RatesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

