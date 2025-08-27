//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _showDatabaseUnlocker(
        _ databaseRef: URLReference,
        andThen activation: DatabaseUnlockerActivationType
    ) {
        let databaseUnlockerCoordinator = DatabaseUnlockerCoordinator(
            router: _router,
            databaseRef: databaseRef
        )
        databaseUnlockerCoordinator.delegate = self
        databaseUnlockerCoordinator.setDatabase(databaseRef, andThen: activation)

        databaseUnlockerCoordinator.start()
        addChildCoordinator(databaseUnlockerCoordinator, onDismiss: { [weak self] _ in
            self?._databaseUnlockerCoordinator = nil
        })
        self._databaseUnlockerCoordinator = databaseUnlockerCoordinator
    }
}

extension AutoFillCoordinator: DatabaseUnlockerCoordinatorDelegate {
    func shouldDismissFromKeyboard(_ coordinator: DatabaseUnlockerCoordinator) -> Bool {
        return true
    }

    func shouldAutoUnlockDatabase(
        _ fileRef: URLReference,
        in coordinator: DatabaseUnlockerCoordinator
    ) -> Bool {
        return true
    }

    func willUnlockDatabase(_ fileRef: URLReference, in coordinator: DatabaseUnlockerCoordinator) {
        assert(_memoryFootprintBeforeDatabaseMiB == nil)
        _memoryFootprintBeforeDatabaseMiB = MemoryMonitor.getMemoryFootprintMiB()
        Diag.debug(String(format: "Memory use before loading: %.1f MiB", _memoryFootprintBeforeDatabaseMiB!))

        Settings.current.isAutoFillFinishedOK = false
    }

    func didNotUnlockDatabase(
        _ fileRef: URLReference,
        with message: String?,
        reason: String?,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        Settings.current.isAutoFillFinishedOK = true
        _memoryFootprintBeforeDatabaseMiB = nil
    }

    func shouldChooseFallbackStrategy(
        for fileRef: URLReference,
        in coordinator: DatabaseUnlockerCoordinator
    ) -> UnreachableFileFallbackStrategy {
        return DatabaseSettingsManager.shared.getFallbackStrategy(fileRef, forAutoFill: true)
    }

    func didUnlockDatabase(
        databaseFile: DatabaseFile,
        at fileRef: URLReference,
        warnings: DatabaseLoadingWarnings,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        if let _memoryFootprintBeforeDatabaseMiB {
            let currentFootprintMiB = MemoryMonitor.getMemoryFootprintMiB()
            Diag.debug(String(format: "Memory use after loading: %.1f MiB", currentFootprintMiB))
            _databaseMemoryFootprintMiB = max(currentFootprintMiB - _memoryFootprintBeforeDatabaseMiB, 0)
            let kdfMemoryFootprintMiB = MemoryMonitor.bytesToMiB(databaseFile.database.peakKDFMemoryFootprint)
            Diag.debug(String(
                format: "DB memory footprint: %.1f MiB KDF + %.1f MiB data",
                kdfMemoryFootprintMiB,
                _databaseMemoryFootprintMiB!
            ))
        } else {
            assertionFailure("memoryAvailableBeforeDatabaseLoad is unexpectedly nil")
        }
        _memoryFootprintBeforeDatabaseMiB = nil

        Settings.current.isAutoFillFinishedOK = true
        if let targetRecord = _quickTypeRequiredRecord,
           let desiredEntry = _findEntry(matching: targetRecord, in: databaseFile),
           _autoFillMode != .passkeyRegistration
        {
            log.trace("Unlocked and found a match")
            _returnEntry(
                desiredEntry,
                from: databaseFile,
                shouldSave: false,
                keepClipboardIntact: false
            )
        } else {
            _showEntryFinder(fileRef, databaseFile: databaseFile, warnings: warnings)
        }
    }

    func didPressReinstateDatabase(
        _ fileRef: URLReference,
        in coordinator: DatabaseUnlockerCoordinator
    ) {
        _router.pop(animated: true, completion: { [weak self] in
            self?._reinstateDatabase(fileRef)
        })
    }

    func didPressAddRemoteDatabase(in coordinator: DatabaseUnlockerCoordinator) {
        _router.pop(animated: true, completion: { [weak self] in
            guard let self else { return }
            _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
                bypassPaywall: true,
                presenter: _router.navigationController
            )
        })
    }
}
