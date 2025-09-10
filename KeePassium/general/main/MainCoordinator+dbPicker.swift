//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _createDatabase() {
        guard let dbViewer = _databaseViewerCoordinator else {
            _databasePickerCoordinator.paywalledStartDatabaseCreator(presenter: _rootSplitVC)
            return
        }
        dbViewer.closeDatabase(
            shouldLock: false,
            reason: .appLevelOperation,
            animated: true,
            completion: { [weak self] in
                guard let self else { return }
                _databasePickerCoordinator.paywalledStartDatabaseCreator(presenter: _rootSplitVC)
            }
        )
    }

    internal func _openDatabase() {
        guard let dbViewer = _databaseViewerCoordinator else {
            _databasePickerCoordinator.paywalledStartExternalDatabasePicker(presenter: _rootSplitVC)
            return
        }
        dbViewer.closeDatabase(
            shouldLock: false,
            reason: .appLevelOperation,
            animated: true,
            completion: { [weak self] in
                guard let self else { return }
                _databasePickerCoordinator.paywalledStartExternalDatabasePicker(presenter: _rootSplitVC)
            }
        )
    }

    internal func _connectToServer() {
        guard let dbViewer = _databaseViewerCoordinator else {
            _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
                bypassPaywall: true,
                presenter: _rootSplitVC)
            return
        }
        dbViewer.closeDatabase(
            shouldLock: false,
            reason: .appLevelOperation,
            animated: true,
            completion: { [weak self] in
                guard let self else { return }
                _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
                    bypassPaywall: true,
                    presenter: _rootSplitVC
                )
            }
        )
    }

    internal func _reinstateDatabase(_ fileRef: URLReference) {
        switch fileRef.location {
        case .external:
            _databasePickerCoordinator.startExternalDatabasePicker(fileRef, presenter: _presenterForModals)
        case .remote:
            _databasePickerCoordinator.startRemoteDatabasePicker(
                mode: .reauth(fileRef),
                presenter: _presenterForModals)
        case .internalBackup, .internalDocuments, .internalInbox:
            assertionFailure("Should not be here. Can reinstate only external or remote files.")
            return
        }
    }
}

extension MainCoordinator: DatabasePickerCoordinatorDelegate {
    func didSelectDatabase(
        _ fileRef: URLReference?,
        cause: ItemActivationCause?,
        in coordinator: DatabasePickerCoordinator
    ) {
        switch cause {
        case .keyPress:
            _setDatabase(fileRef, andThen: .unlock)
        case .touch:
            if _rootSplitVC.isCollapsed {
                _setDatabase(fileRef, andThen: .unlock)
            } else {
                _setDatabase(fileRef, andThen: .doNothing)
            }
        case .app:
            _setDatabase(fileRef, andThen: .unlock)
        case nil:
            _setDatabase(fileRef, andThen: .doNothing)
        }
    }

    func didPressShowRandomGenerator(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        _showPasswordGenerator(at: popoverAnchor, in: viewController)
    }

    func didPressShowAppSettings(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        _showSettingsScreen(in: viewController)
    }

    func didPressShowDiagnostics(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        _showDiagnostics(in: viewController)
    }
}
