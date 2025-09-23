//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    private static let lockCheckInterval: TimeInterval = 1.0

    internal func _updateUserActivityTimestamp() {
        if let _cachedUserActivityTimestamp {
            let timeSinceLastUpdate = Date.now.timeIntervalSince(_cachedUserActivityTimestamp)
            guard timeSinceLastUpdate > Self.lockCheckInterval else {
                return
            }
        }
        DatabaseSettingsManager.shared.updateUserActivityTimestamp(for: _databaseFile.originalReference)
    }

    internal func _setupDatabaseLockTimer() {
        assert(_databaseLockTimer == nil)
        _databaseLockTimer = DispatchSource.makeTimerSource(queue: .main)
        _databaseLockTimer.schedule(deadline: .now(), repeating: Self.lockCheckInterval)
        _databaseLockTimer.setEventHandler { [weak self] in
            self?._lockDatabaseIfExpired()
        }
        _databaseLockTimer.resume()
    }

    internal func _lockDatabaseIfExpired() {
        guard DatabaseSettingsManager.shared.isLockExpired(_databaseFile.originalReference) else {
            return
        }
        Diag.info("Database lock expired, closing database")
        closeDatabase(
            shouldLock: Settings.current.isLockDatabasesOnTimeout,
            reason: .databaseTimeout,
            animated: false,
            completion: nil
        )
    }
}
