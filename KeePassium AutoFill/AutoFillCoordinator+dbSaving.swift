//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _saveDatabaseWithoutUI(_ databaseFile: DatabaseFile) {
        assert(_databaseSaver == nil)
        log.debug("Will save database")

        _databaseSaver = DatabaseSaver(
            databaseFile: databaseFile,
            skipTasks: [.updateQuickAutoFill],
            timeoutDuration: 10,
            delegate: self
        )
        _databaseSaver?.save()
    }
}

extension AutoFillCoordinator: DatabaseSaverDelegate {
    func databaseSaver(_ databaseSaver: DatabaseSaver, willSave databaseFile: DatabaseFile) {
        log.debug("Saving database…")
    }

    func databaseSaver(
        _ databaseSaver: DatabaseSaver,
        didChangeProgress progress: ProgressEx,
        for databaseFile: DatabaseFile
    ) {
    }

    func databaseSaverResolveConflict(
        _ databaseSaver: DatabaseSaver,
        local: DatabaseFile,
        remoteURL: URL,
        remoteData: ByteArray,
        completion: @escaping DatabaseSaver.ConflictResolutionHandler
    ) {
        log.error("Sync conflict when saving database, cancelling")
        completion(.cancel)
    }

    func databaseSaver(_ databaseSaver: DatabaseSaver, didCancelSaving databaseFile: DatabaseFile) {
        self._databaseSaver = nil
    }

    func databaseSaver(_ databaseSaver: DatabaseSaver, didSave databaseFile: DatabaseFile) {
        log.info("Database successfully saved")
        self._databaseSaver = nil
    }

    func databaseSaver(
        _ databaseSaver: DatabaseSaver,
        didFailSaving databaseFile: DatabaseFile,
        with error: any Error
    ) {
        log.error("Database saving failed: \(error)")
        self._databaseSaver = nil
    }

}
