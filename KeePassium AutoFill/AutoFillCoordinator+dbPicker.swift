//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _reinstateDatabase(_ fileRef: URLReference) {
        let presenter = _router.navigationController
        switch fileRef.location {
        case .external:
            _databasePickerCoordinator.startExternalDatabasePicker(fileRef, presenter: presenter)
        case .remote:
            _databasePickerCoordinator.startRemoteDatabasePicker(
                mode: .reauth(fileRef),
                presenter: presenter)
        case .internalInbox, .internalBackup, .internalDocuments:
            assertionFailure("Should not be here. Can reinstate only external or remote files.")
            return
        }
    }
}

extension AutoFillCoordinator: DatabasePickerCoordinatorDelegate {
    func didSelectDatabase(
        _ fileRef: URLReference?,
        cause: ItemActivationCause?,
        in coordinator: DatabasePickerCoordinator
    ) {
        assert(cause != nil, "Unexpected for single-panel mode")
        guard let fileRef else { return }
        switch cause {
        case .keyPress, .touch, .app:
            _showDatabaseUnlocker(fileRef, andThen: .unlock)
        case nil:
            _showDatabaseUnlocker(fileRef, andThen: .doNothing)
        }

    }

    func didPressShowDiagnostics(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        _showDiagnostics()
    }
}
