//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit

extension GroupViewerVC {
    func activateManualSearch() {
        DispatchQueue.main.async { [self] in
            _searchController.isActive = true
            _searchController.searchBar.becomeFirstResponderWhenSafe()

            updateSearchResults(for: _searchController)
        }
    }

    func cancelSearch() {
        _searchController.searchBar.text = nil
        _searchController.isActive = false
    }

    internal func _setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.barStyle = .default
        searchController.searchBar.delegate = self

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        definesPresentationContext = true
        self._searchController = searchController
    }
}

extension GroupViewerVC: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        delegate?.didChangeSearchQuery(searchText, in: self)
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponderWhenSafe()
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = nil
    }
}

extension GroupViewerVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        _didPressEnter()
    }
}
