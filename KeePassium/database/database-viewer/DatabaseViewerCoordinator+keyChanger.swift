//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _showMasterKeyChanger(in viewController: UIViewController? = nil) {
        Diag.info("Will change master key")
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let databaseKeyChangeCoordinator = DatabaseKeyChangerCoordinator(
            databaseFile: _databaseFile,
            router: modalRouter
        )
        databaseKeyChangeCoordinator.delegate = self
        databaseKeyChangeCoordinator.start()

        let presenter = viewController ?? _presenterForModals
        presenter.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(databaseKeyChangeCoordinator, onDismiss: nil)
    }
}

extension DatabaseViewerCoordinator: DatabaseKeyChangerCoordinatorDelegate {
    func didChangeDatabaseKey(in coordinator: DatabaseKeyChangerCoordinator) {
        _presenterForModals.showNotification(LString.masterKeySuccessfullyChanged)
    }
}
