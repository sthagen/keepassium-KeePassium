//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import AuthenticationServices
import KeePassiumLib

extension EntryFinderCoordinator {
    internal func _updateData(_ context: AutoFillSearchContext) {
        if let userQuery = context.userQuery {
            performManualSearch(query: userQuery)
        } else {
            performAutomaticSearch(context)
        }
    }

    private func performManualSearch(query: String) {
        let foundItems = _searchHelper.findEntries(
            in: _databaseFile.database,
            searchText: query,
            onlyAutoFillable: true
        )
        if query.isEmpty {
            _entryFinderVC.setOverviewData(foundItems)
            _entryFinderVC.setRecentEntry(_recentEntry)
        } else {
            _entryFinderVC.setManuallyFoundData(foundItems)
            _entryFinderVC.setRecentEntry(nil)
        }
    }

    private func performAutomaticSearch(_ context: AutoFillSearchContext) {
        let searchResults = _searchHelper.find(
            database: _databaseFile.database,
            serviceIdentifiers: context.serviceIdentifiers,
            passkeyRelyingParty: context.passkeyRelyingParty,
            allowOnly: context.itemKind
        )

        _entryFinderVC.setRecentEntry(_recentEntry)

        switch _autoFillMode {
        case .credentials, .oneTimeCode, .passkeyAssertion, .text, .none:
            if searchResults.isEmpty {
                _entryFinderVC.activateManualSearch()
                return
            }
            _entryFinderVC.setAutomaticallyFoundData(searchResults)
            if let perfectMatch = searchResults.perfectMatch,
               Settings.current.autoFillPerfectMatch
            {
                _entryFinderVC.selectEntry(perfectMatch, animated: true)
                _notifyEntrySelected(perfectMatch, rememberURL: nil)
                return
            }
        case .passkeyRegistration:
            _entryFinderVC.setAutomaticallyFoundData(searchResults)
        }
    }
}
