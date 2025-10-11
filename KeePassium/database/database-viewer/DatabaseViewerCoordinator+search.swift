//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _maybeActivateInitialSearch() {
        if Settings.current.isStartWithSearch {
            DispatchQueue.main.async { [weak self] in
                self?._groupViewers.last?.activateManualSearch()
            }
        }
    }

    internal func _didChangeSearchQuery(_ text: String?, in viewController: GroupViewerVC) {
        self._searchQuery = text
        refresh()

        if _isSearchOngoing && viewController.isEditing {
            assertionFailure("Changing search query is forbidden in editing mode")
            viewController.endBulkEditing(animated: false)
            _saveUnsavedBulkChanges(onSuccess: nil)
        }
    }

    internal func _updateData(searchQuery: String?) {
        guard let group = _currentGroup,
              let groupViewerVC = _topGroupViewer
        else { assertionFailure(); return }

        guard let searchQuery, searchQuery.isNotEmpty else {
            _showGroupContent(group, in: groupViewerVC)
            return
        }

        let searchResults = _searchHelper.findEntriesAndGroups(
            in: _database,
            searchText: searchQuery,
            onlyAutoFillable: false,
            excludeGroupUUID: group.isSmartGroup ? group.uuid : nil
        )
        groupViewerVC.setManualSearchResults(searchResults)
    }
}
