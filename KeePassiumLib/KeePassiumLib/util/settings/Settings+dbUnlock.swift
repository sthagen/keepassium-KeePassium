//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public var startupDatabase: URLReference? {
        get {
            try? Keychain.shared.getFileReference(of: .startDatabase)
        }
        set {
            let oldValue = startupDatabase
            try? Keychain.shared.setFileReference(newValue, for: .startDatabase)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.startupDatabase)
            }
        }
    }

    public var isAutoUnlockStartupDatabase: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.autoUnlockLastDatabase) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.autoUnlockStartupDatabase.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isAutoUnlockStartupDatabase,
                newValue: newValue,
                key: .autoUnlockStartupDatabase)
        }
    }

    public var isRememberDatabaseKey: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.rememberDatabaseKey) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.rememberDatabaseKey.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isRememberDatabaseKey,
                newValue: newValue,
                key: .rememberDatabaseKey)
        }
    }

    public var isRememberDatabaseFinalKey: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.rememberDatabaseFinalKey) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.rememberDatabaseFinalKey.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isRememberDatabaseFinalKey,
                newValue: newValue,
                key: .rememberDatabaseFinalKey)
        }
    }

    public var isKeepKeyFileAssociations: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.keepKeyFileAssociations) {
                return managedValue
            }
            if _contains(key: Keys.keepKeyFileAssociations) {
                return UserDefaults.appGroupShared.bool(forKey: Keys.keepKeyFileAssociations.rawValue)
            } else {
                return true
            }
        }
        set {
            let oldValue = isKeepKeyFileAssociations
            UserDefaults.appGroupShared.set(newValue, forKey: Keys.keepKeyFileAssociations.rawValue)
            if !newValue {
                DatabaseSettingsManager.shared.forgetAllKeyFiles()
            }
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.keepKeyFileAssociations)
            }
        }
    }

    public var isKeepHardwareKeyAssociations: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.keepHardwareKeyAssociations) {
                return managedValue
            }
            if _contains(key: Keys.keepHardwareKeyAssociations) {
                return UserDefaults.appGroupShared.bool(forKey: Keys.keepHardwareKeyAssociations.rawValue)
            } else {
                return true
            }
        }
        set {
            let oldValue = isKeepHardwareKeyAssociations
            UserDefaults.appGroupShared.set(newValue, forKey: Keys.keepHardwareKeyAssociations.rawValue)
            if !newValue {
                DatabaseSettingsManager.shared.forgetAllHardwareKeys()
            }
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.keepHardwareKeyAssociations)
            }
        }
    }

    public var isKeyFileInputProtected: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.protectKeyFileInput) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.keyFileEntryProtected.rawValue) as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isKeyFileInputProtected,
                newValue: newValue,
                key: .keyFileEntryProtected
            )
        }
    }
}
