//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {
    public var isAutoFillFinishedOK: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.autoFillFinishedOK.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isAutoFillFinishedOK,
                newValue: newValue,
                key: Keys.autoFillFinishedOK)

            UserDefaults.appGroupShared.synchronize()
        }
    }

    public var isCopyTOTPOnAutoFill: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.copyTOTPOnAutoFill.rawValue)
                as? Bool

            if #available(iOS 18, *) {
                return stored ?? false
            } else {
                return stored ?? true
            }
        }
        set {
            _updateAndNotify(
                oldValue: isCopyTOTPOnAutoFill,
                newValue: newValue,
                key: .copyTOTPOnAutoFill)
        }
    }

    public var autoFillPerfectMatch: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.autoFillPerfectMatch.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: autoFillPerfectMatch,
                newValue: newValue,
                key: .autoFillPerfectMatch)
        }
    }

    public var acceptAutoFillInput: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.acceptAutoFillInput.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: acceptAutoFillInput,
                newValue: newValue,
                key: .acceptAutoFillInput)
        }
    }

    public var isQuickTypeEnabled: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.enableQuickTypeAutoFill) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.quickTypeEnabled.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isQuickTypeEnabled,
                newValue: newValue,
                key: .quickTypeEnabled)
        }
    }
}
