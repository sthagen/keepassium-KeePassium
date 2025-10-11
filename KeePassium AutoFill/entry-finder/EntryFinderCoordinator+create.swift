//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {
    internal var _canCreateEntries: Bool {
        let readOnly = _databaseFile.status.contains(.readOnly)
        return !readOnly
    }

    func _showEntryCreator() {
        guard _canCreateEntries else {
            Diag.warning("Tried to edit a read-only database, cancelling")
            assertionFailure()
            return
        }
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let coordinator = EntryCreatorCoordinator(
            router: modalRouter,
            databaseFile: _databaseFile,
            searchContext: _searchContext)
        coordinator.start()
        coordinator.delegate = self
        addChildCoordinator(coordinator, onDismiss: nil)
        _presenterForModals.present(modalRouter, animated: true, completion: nil)
    }
}

extension EntryFinderCoordinator: EntryCreatorCoordinatorDelegate {
    func didCreateEntry(_ entry: Entry, in coordinator: EntryCreatorCoordinator) {
        coordinator.dismiss(animated: true) { [weak self] in
            self?._notifyEntryCreated(entry)
        }
    }
}
