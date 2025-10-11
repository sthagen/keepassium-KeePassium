//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderVC {

    func activateManualSearch() {
        DispatchQueue.main.async { [self] in
            _searchController.isActive = true
            _searchController.searchBar.becomeFirstResponderWhenSafe()

            updateSearchResults(for: _searchController)
        }
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

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        definesPresentationContext = true
        self._searchController = searchController
    }
}

extension EntryFinderVC: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        Watchdog.shared.restart()
        let searchText = searchController.searchBar.text ?? ""
        delegate?.didChangeSearchQuery(searchText, in: self)
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponderWhenSafe()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Watchdog.shared.restart()
    }
}

extension EntryFinderVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        _didPressEnter()
    }
}
