//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _showItemRelocator(for items: [DatabaseItem], mode: ItemRelocationMode) {
        Diag.info("Will relocate item [mode: \(mode)]")
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let itemRelocationCoordinator = ItemRelocationCoordinator(
            router: modalRouter,
            databaseFile: _databaseFile,
            mode: mode,
            itemsToRelocate: items.map({ Weak($0) }))
        itemRelocationCoordinator.delegate = self
        itemRelocationCoordinator.start()

        _presenterForModals.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(itemRelocationCoordinator, onDismiss: nil)
    }

    func didDragItems(_ items: [DatabaseItem], into targetGroup: Group) {
        let isValidDestination = items.allSatisfy { _canMoveItem($0, to: targetGroup) }
        guard isValidDestination else { return }

        items.forEach {
            $0.move(to: targetGroup)
            $0.touch(.accessed, updateParents: true)
        }
        _hasUnsavedBulkChanges = true
        _saveUnsavedBulkChanges(onSuccess: nil)
    }
}

extension DatabaseViewerCoordinator: ItemRelocationCoordinatorDelegate {
    func didRelocateItems(in coordinator: ItemRelocationCoordinator) {
        _presenterForModals.showSuccessNotification(
            LString.actionDone,
            icon: .arrowshapeTurnUpForward
        )
        refresh()
    }
}
