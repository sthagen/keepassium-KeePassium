//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public enum BackupKeepingDuration: Int {
        public static let allValues: [BackupKeepingDuration] = [
            .forever, _1year, _6months, _2months, _4weeks, _1week, _1day, _4hours, _1hour
        ]
        case _1hour = 3600
        case _4hours = 14400
        case _1day = 86400
        case _1week = 604_800
        case _4weeks = 2_419_200
        case _2months = 5_270_400
        case _6months = 15_552_000
        case _1year = 31_536_000
        case forever

        public var seconds: TimeInterval {
            switch self {
            case .forever:
                return TimeInterval.infinity
            default:
                return TimeInterval(self.rawValue)
            }
        }

        static func nearest(forSeconds seconds: Int) -> BackupKeepingDuration {
            let result = Self.allValues.min(by: { item1, item2 in
                return abs(item1.rawValue - seconds) < abs(item2.rawValue - seconds)
            })
            return result!
        }
    }

    public var isBackupDatabaseOnLoad: Bool {
      return isBackupDatabaseOnSave
    }

    public var isBackupDatabaseOnSave: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.backupDatabaseOnSave) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.backupDatabaseOnSave.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isBackupDatabaseOnSave,
                newValue: newValue,
                key: .backupDatabaseOnSave)
        }
    }

    public var backupKeepingDuration: BackupKeepingDuration {
        get {
            if let managedValue = ManagedAppConfig.shared.getIntIfLicensed(.backupKeepingDuration) {
                let nearestDuration = BackupKeepingDuration.nearest(forSeconds: managedValue)
                return nearestDuration
            }

            if let stored = UserDefaults.appGroupShared
                    .object(forKey: Keys.backupKeepingDuration.rawValue) as? Int,
               let timeout = BackupKeepingDuration(rawValue: stored)
            {
                return timeout
            }
            return BackupKeepingDuration._2months
        }
        set {
            let oldValue = backupKeepingDuration
            UserDefaults.appGroupShared.set(
                newValue.rawValue,
                forKey: Keys.backupKeepingDuration.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.backupKeepingDuration)
            }
        }
    }

    public var isExcludeBackupFilesFromSystemBackup: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.excludeBackupFilesFromSystemBackup) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.excludeBackupFilesFromSystemBackup.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isExcludeBackupFilesFromSystemBackup,
                newValue: newValue,
                key: .excludeBackupFilesFromSystemBackup)
        }
    }
}
