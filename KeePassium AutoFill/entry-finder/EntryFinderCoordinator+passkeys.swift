//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {
    internal var _canCreatePasskeys: Bool {
        let compatibleFormat = _databaseFile.database is Database2
        let readOnly = _databaseFile.status.contains(.readOnly)
        return compatibleFormat && !readOnly
    }

    internal func _showPasskeyRegistration(_ params: PasskeyRegistrationParams) {
        guard _canCreatePasskeys else {
            Diag.warning("Cannot create passkeys in this database, cancelling")
            return
        }
        let creatorVC = PasskeyCreatorVC.make(with: params)
        creatorVC.modalPresentationStyle = .pageSheet
        creatorVC.delegate = self
        if let sheet = creatorVC.sheetPresentationController {
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = true
            sheet.detents = creatorVC.detents()
        }
        _router.present(creatorVC, animated: true, completion: nil)
    }
}

extension EntryFinderCoordinator: PasskeyCreatorDelegate {
    func didPressCreatePasskey(with params: PasskeyRegistrationParams, in viewController: PasskeyCreatorVC) {
        assert(_canCreatePasskeys)
        viewController.dismiss(animated: true) { [self] in
            delegate?.didPressCreatePasskey(
                with: params,
                target: nil,
                databaseFile: _databaseFile,
                presenter: _entryFinderVC,
                in: self
            )
        }
    }

    func didPressAddPasskeyToEntry(
        with params: PasskeyRegistrationParams,
        in viewController: PasskeyCreatorVC
    ) {
        assert(_canCreatePasskeys)
        viewController.dismiss(animated: true)

        _entrySelectionMode = .forPasskeyCreation
        _entryFinderVC.activateManualSearch()
    }

    func didDismiss(_ viewController: PasskeyCreatorVC) {
        assert(_canCreatePasskeys)
        _entrySelectionMode = .forPasskeyCreation
        _entryFinderVC.activateManualSearch()
    }
}
