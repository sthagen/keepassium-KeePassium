//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _showDatabaseUnlocker(
        _ databaseRef: URLReference,
        context: DatabaseReloadContext?
    ) -> DatabaseUnlockerCoordinator {
        if let _databaseUnlockerRouter {
            _rootSplitVC.setSecondaryRouter(_databaseUnlockerRouter)
            if let existingDBUnlocker = childCoordinators.first(where: { $0 is DatabaseUnlockerCoordinator }) {
                let dbUnlocker = existingDBUnlocker as! DatabaseUnlockerCoordinator
                dbUnlocker.reloadingContext = context
                return dbUnlocker
            } else {
                Diag.warning("Internal inconsistency: router without coordinator")
                assertionFailure()
            }
        }

        let dbUnlockerRouter = NavigationRouter(RouterNavigationController())
        self._databaseUnlockerRouter = dbUnlockerRouter

        let dbUnlockerCoordinator = DatabaseUnlockerCoordinator(
            router: dbUnlockerRouter,
            databaseRef: databaseRef
        )
        dbUnlockerCoordinator.delegate = self
        dbUnlockerCoordinator.reloadingContext = context
        dbUnlockerCoordinator.start()
        addChildCoordinator(dbUnlockerCoordinator, onDismiss: { [weak self] _ in
            self?._databaseUnlockerRouter = nil
        })
        _rootSplitVC.setSecondaryRouter(dbUnlockerRouter)

        return dbUnlockerCoordinator
    }
}

extension MainCoordinator: DatabaseUnlockerCoordinatorDelegate {
    func shouldDismissFromKeyboard(_ coordinator: DatabaseUnlockerCoordinator) -> Bool {
        if _rootSplitVC.isCollapsed {
            return true
        } else {
            return false
        }
    }

    func willUnlockDatabase(_ fileRef: URLReference, in coordinator: DatabaseUnlockerCoordinator) {
        _databasePickerCoordinator.setEnabled(false)
        _isInitialDatabase = false
    }

    func didNotUnlockDatabase(
        _ fileRef: URLReference,
        with message: String?,
        reason: String?,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        _databasePickerCoordinator.setEnabled(true)
    }

    func shouldChooseFallbackStrategy(
        for fileRef: URLReference,
        in coordinator: DatabaseUnlockerCoordinator
    ) -> UnreachableFileFallbackStrategy {
        return DatabaseSettingsManager.shared.getFallbackStrategy(fileRef, forAutoFill: false)
    }

    func didUnlockDatabase(
        databaseFile: DatabaseFile,
        at fileRef: URLReference,
        warnings: DatabaseLoadingWarnings,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        _databasePickerCoordinator.setEnabled(true)

        _showDatabaseViewer(
            fileRef,
            databaseFile: databaseFile,
            context: coordinator.reloadingContext,
            warnings: warnings
        )
    }

    func didPressReinstateDatabase(
        _ fileRef: URLReference,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        if _rootSplitVC.isCollapsed {
            _primaryRouter.pop(animated: true, completion: { [weak self] in
                self?._reinstateDatabase(fileRef)
            })
        } else {
            _reinstateDatabase(fileRef)
        }
    }

    func didPressAddRemoteDatabase(in coordinator: DatabaseUnlockerCoordinator) {
        if _rootSplitVC.isCollapsed {
            _primaryRouter.pop(animated: true) { [weak self] in
                guard let self else { return }
                _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
                    bypassPaywall: true,
                    presenter: _rootSplitVC
                )
            }
        } else {
            _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
                bypassPaywall: true,
                presenter: _rootSplitVC
            )
        }
    }
}
