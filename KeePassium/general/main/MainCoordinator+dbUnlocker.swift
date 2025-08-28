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
            _rootSplitVC.setDetailRouter(_databaseUnlockerRouter)
            if let existingDBUnlocker = childCoordinators.first(where: { $0 is DatabaseUnlockerCoordinator }) {
                let dbUnlocker = existingDBUnlocker as! DatabaseUnlockerCoordinator
                dbUnlocker.reloadingContext = context
                return dbUnlocker
            } else {
                Diag.warning("Internal inconsistency: router without coordinator")
                assertionFailure()
            }
        }

        _databaseUnlockerRouter = NavigationRouter(RouterNavigationController())
        let router = _databaseUnlockerRouter!

        let newDBUnlockerCoordinator = DatabaseUnlockerCoordinator(
            router: router,
            databaseRef: databaseRef
        )
        newDBUnlockerCoordinator.delegate = self
        newDBUnlockerCoordinator.reloadingContext = context
        newDBUnlockerCoordinator.start()
        addChildCoordinator(newDBUnlockerCoordinator, onDismiss: { [weak self] _ in
            self?._databaseUnlockerRouter = nil
        })

        _rootSplitVC.setDetailRouter(router)

        return newDBUnlockerCoordinator
    }

    internal func _deallocateDatabaseUnlocker() {
        _databaseUnlockerRouter = nil
        childCoordinators.removeAll(where: { $0 is DatabaseUnlockerCoordinator })
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
