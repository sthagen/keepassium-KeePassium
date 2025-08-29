//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _showDatabaseViewer(
        _ fileRef: URLReference,
        databaseFile: DatabaseFile,
        context: DatabaseReloadContext?,
        warnings: DatabaseLoadingWarnings
    ) {
        let dbViewerCoordinator = DatabaseViewerCoordinator(
            splitViewController: _rootSplitVC,
            primaryRouter: _primaryRouter,
            databaseFile: databaseFile,
            context: context,
            loadingWarnings: warnings,
            autoTypeHelper: _autoTypeHelper
        )
        dbViewerCoordinator.delegate = self
        dbViewerCoordinator.start()
        addChildCoordinator(dbViewerCoordinator, onDismiss: { [weak self] _ in
            self?._databaseViewerCoordinator = nil
            UIMenu.rebuildMainMenu()
        })
        self._databaseViewerCoordinator = dbViewerCoordinator
        UIMenu.rebuildMainMenu()
    }

    internal func _reloadDatabase(
        _ databaseFile: DatabaseFile,
        from databaseViewerCoordinator: DatabaseViewerCoordinator
    ) {
        let targetRef = databaseFile.originalReference

        let context = DatabaseReloadContext(for: databaseFile.database)
        context.groupUUID = databaseViewerCoordinator.currentGroupUUID

        databaseViewerCoordinator.closeDatabase(
            shouldLock: false,
            reason: .userRequest,
            animated: true
        ) { [weak self] in
            guard let self else { return }
            _setDatabase(targetRef, autoOpenWith: context, andThen: .unlock)
        }
    }

    internal func _switchToDatabase(
        _ fileRef: URLReference,
        key: CompositeKey,
        in databaseViewerCoordinator: DatabaseViewerCoordinator
    ) {
        let context = DatabaseReloadContext(key: key)

        databaseViewerCoordinator.closeDatabase(
            shouldLock: false,
            reason: .userRequest,
            animated: true
        ) { [weak self] in
            guard let self else { return }
            _setDatabase(fileRef, autoOpenWith: context, andThen: .unlock)
        }
    }

    internal func _lockDatabase() {
        assert(_databaseViewerCoordinator != nil, "Tried to lock database, but there is none opened")
        _databaseViewerCoordinator?.closeDatabase(
            shouldLock: true,
            reason: .userRequest,
            animated: true,
            completion: nil
        )
    }
}

extension MainCoordinator: DatabaseViewerCoordinatorDelegate {
    func didRelocateDatabase(_ databaseFile: DatabaseFile, to url: URL) {
        Diag.debug("Will account relocated database")
        let fileKeeper = FileKeeper.shared

        if let oldReference = databaseFile.fileReference,
           fileKeeper.removeExternalReference(oldReference, fileType: .database)
        {
            Diag.debug("Did remove old reference")
        } else {
            Diag.debug("No old reference found")
        }

        databaseFile.fileURL = url
        fileKeeper.addFile(url: url, fileType: .database, mode: .openInPlace) { result in
            switch result {
            case .success(let fileRef):
                Diag.info("Relocated database reference added OK")
                databaseFile.fileReference = fileRef
            case .failure(let fileKeeperError):
                Diag.error("Failed to add relocated database [message: \(fileKeeperError.localizedDescription)")
            }
        }
    }

    func didLeaveDatabase(in coordinator: DatabaseViewerCoordinator) {
        Diag.debug("Did leave database")

        if !_rootSplitVC.isCollapsed {
            _setDatabase(_selectedDatabaseRef, andThen: .doNothing)
            _databasePickerCoordinator.becomeFirstResponder()
        }
    }

    func didPressReinstateDatabase(_ fileRef: URLReference, in coordinator: DatabaseViewerCoordinator) {
        _databaseViewerCoordinator?.closeDatabase(
            shouldLock: false,
            reason: .userRequest,
            animated: true
        ) { [weak self] in
            self?._reinstateDatabase(fileRef)
        }
    }

    func didPressReloadDatabase(
        _ databaseFile: DatabaseFile,
        in coordinator: DatabaseViewerCoordinator
    ) {
        _reloadDatabase(databaseFile, from: coordinator)
    }

    func didPressSwitchTo(
        databaseRef: URLReference,
        compositeKey: CompositeKey,
        in coordinator: DatabaseViewerCoordinator
    ) {
        _switchToDatabase(databaseRef, key: compositeKey, in: coordinator)
    }
}
