//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings.Keys {
    internal var managedKeyMapping: ManagedAppConfig.Key? {
        switch self {
        case .backupFilesVisible:
            return .showBackupFiles
        case .autoUnlockStartupDatabase:
            return .autoUnlockLastDatabase
        case .rememberDatabaseKey:
            return .rememberDatabaseKey
        case .rememberDatabaseFinalKey:
            return .rememberDatabaseFinalKey
        case .keepKeyFileAssociations:
            return .keepKeyFileAssociations
        case .keepHardwareKeyAssociations:
            return .keepHardwareKeyAssociations
        case .lockAllDatabasesOnFailedPasscode:
            return .lockAllDatabasesOnFailedPasscode
        case .appLockTimeout:
            return .appLockTimeout
        case .lockAppOnLaunch:
            return .lockAppOnLaunch
        case .databaseLockTimeout:
            return .databaseLockTimeout
        case .lockDatabasesOnTimeout:
            return .lockDatabasesOnTimeout
        case .lockDatabasesOnReboot:
            return .lockDatabasesOnReboot
        case .clipboardTimeout:
            return .clipboardTimeout
        case .universalClipboardEnabled:
            return .useUniversalClipboard
        case .hideProtectedFields:
            return .hideProtectedFields
        case .backupDatabaseOnSave:
            return .backupDatabaseOnSave
        case .backupKeepingDuration:
            return .backupKeepingDuration
        case .excludeBackupFilesFromSystemBackup:
            return .excludeBackupFilesFromSystemBackup
        case .quickTypeEnabled:
            return .enableQuickTypeAutoFill
        case .networkAccessAllowed:
            return .allowNetworkAccess
        case .hideAppLockSetupReminder:
            return .hideAppLockSetupReminder
        default:
            return nil
        }
    }
}

extension Settings {
    public func isManaged(key: Keys) -> Bool {
        guard let managedKey = key.managedKeyMapping else {
            return false
        }
        return ManagedAppConfig.shared.isManaged(key: managedKey)
    }
}
