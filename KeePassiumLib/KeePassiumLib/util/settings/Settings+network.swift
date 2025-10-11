//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public var isNetworkAccessAllowed: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.allowNetworkAccess) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.networkAccessAllowed.rawValue) as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isNetworkAccessAllowed,
                newValue: newValue,
                key: .networkAccessAllowed
            )
        }
    }

    public var isAutoDownloadFaviconsEnabled: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.allowFaviconDownload),
               !managedValue
            {
                return false
            }

            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.autoDownloadFaviconsEnabled.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isAutoDownloadFaviconsEnabled,
                newValue: newValue,
                key: .autoDownloadFaviconsEnabled)
        }
    }
}
