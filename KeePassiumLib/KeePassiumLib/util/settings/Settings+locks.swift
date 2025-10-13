//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {
    public enum AppLockTimeout: Int {
        public enum TriggerMode {
            case userIdle
            case appMinimized
        }

        public static var allValues: [Self] = {
            if ProcessInfo.isRunningOnMac {
                return [
                    after10seconds, after15seconds, after30seconds,
                    after1minute, after2minutes, after5minutes]
            } else {
                return [
                    immediately,
                    after3seconds, after15seconds, after30seconds,
                    after1minute, after2minutes, after5minutes]
            }
        }()

        case never = -1
        case immediately = 0
        case almostImmediately = 2 /* workaround for some bugs with `immediately` */
        case after3seconds = 3
        case after5seconds = 5
        case after10seconds = 10
        case after15seconds = 15
        case after30seconds = 30
        case after1minute = 60
        case after2minutes = 120
        case after5minutes = 300

        private static let screenLockAdjustment = 1.0
        public var seconds: TimeInterval {
            if self.rawValue >= 30 {
                /* Prevents device lock disruption by app lock / biometric prompt.
                   https://github.com/keepassium/KeePassium/issues/19 */
                return TimeInterval(self.rawValue) + Self.screenLockAdjustment
            } else {
                return TimeInterval(self.rawValue)
            }
        }

        static func nearest(forSeconds seconds: Int) -> AppLockTimeout {
            let result = Self.allValues.min(by: { item1, item2 in
                return abs(item1.rawValue - seconds) < abs(item2.rawValue - seconds)
            })
            return result!
        }

        public var triggerMode: TriggerMode {
            switch self {
            case .never,
                 .immediately,
                 .almostImmediately,
                 .after3seconds:
                return .appMinimized
            default:
                return .userIdle
            }
        }
    }

    public enum DatabaseLockTimeout: Int, Comparable {
        public static let allValues = [
            immediately, /*after5seconds, after15seconds, */after30seconds,
            after1minute, after2minutes, after5minutes, after10minutes,
            after30minutes, after1hour, after2hours, after4hours, after8hours,
            after24hours, after48hours, after7days, never]
        case never = -1
        case immediately = 0
        case after5seconds = 5
        case after15seconds = 15
        case after30seconds = 30
        case after1minute = 60
        case after2minutes = 120
        case after5minutes = 300
        case after10minutes = 600
        case after30minutes = 1800
        case after1hour = 3600
        case after2hours = 7200
        case after4hours = 14400
        case after8hours = 28800
        case after24hours = 86400
        case after48hours = 172800
        case after7days = 604800

        public var seconds: Int {
            return self.rawValue
        }

        static func nearest(forSeconds seconds: Int) -> DatabaseLockTimeout {
            let result = Self.allValues.min(by: { item1, item2 in
                return abs(item1.seconds - seconds) < abs(item2.seconds - seconds)
            })
            return result!
        }

        public static func < (a: DatabaseLockTimeout, b: DatabaseLockTimeout) -> Bool {
            return a.seconds < b.seconds
        }
    }

    public enum PasscodeAttemptsBeforeAppReset: Int, CaseIterable {
        case never = 0
        case after1 = 1
        case after3 = 3
        case after5 = 5
        case after10 = 10

        public static var allCases: [PasscodeAttemptsBeforeAppReset] {
            [after1, after3, after5, after10, never]
        }
    }

    public var isAppLockEnabled: Bool {
      let hasPasscode = try? Keychain.shared.isAppPasscodeSet()
      return hasPasscode ?? false
    }

    internal func notifyAppLockEnabledChanged() {
        _postChangeNotification(changedKey: .appLockEnabled)
    }

    public var isBiometricAppLockEnabled: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.biometricAppLockEnabled.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isBiometricAppLockEnabled,
                newValue: newValue,
                key: .biometricAppLockEnabled)
        }
    }

    public var isLockAllDatabasesOnFailedPasscode: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.lockAllDatabasesOnFailedPasscode) {
                return managedValue
            }
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.lockAllDatabasesOnFailedPasscode) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockAllDatabasesOnFailedPasscode.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isLockAllDatabasesOnFailedPasscode,
                newValue: newValue,
                key: .lockAllDatabasesOnFailedPasscode)
        }
    }

    public var recentUserActivityTimestamp: Date {
        get {
            if let _cachedUserActivityTimestamp,
               abs(_cachedUserActivityTimestamp.timeIntervalSinceNow) < _timestampCacheValidityInterval
            {
                return _cachedUserActivityTimestamp
            }

            do {
                let storedTimestamp = try Keychain.shared.getUserActivityTimestamp()
                _cachedUserActivityTimestamp = storedTimestamp
                return storedTimestamp ?? Date.distantPast
            } catch {
                Diag.error("Failed to get user activity timestamp [message: \(error.localizedDescription)]")
                return Date.distantPast
            }
        }
        set {
            if let _cachedUserActivityTimestamp,
               abs(_cachedUserActivityTimestamp.timeIntervalSinceNow) < _timestampCacheValidityInterval
            {
                return
            }
            do {
                try Keychain.shared.setUserActivityTimestamp(newValue)
                _cachedUserActivityTimestamp = newValue
                _postChangeNotification(changedKey: Keys.recentUserActivityTimestamp)
            } catch {
                Diag.error("Failed to set user activity timestamp [message: \(error.localizedDescription)]")
            }
        }
    }

    private func maybeFixAutoFillBiometricIDLoop(_ timeout: AppLockTimeout) -> AppLockTimeout {
        if timeout == .immediately && AppGroup.isAppExtension {
            return .almostImmediately
        } else {
            return timeout
        }
    }

    public var appLockTimeout: AppLockTimeout {
        get {
            if let managedValue = ManagedAppConfig.shared.getIntIfLicensed(.appLockTimeout) {
                let nearestTimeout = AppLockTimeout.nearest(forSeconds: managedValue)
                return maybeFixAutoFillBiometricIDLoop(nearestTimeout)
            }

            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.appLockTimeout.rawValue) as? Int,
               let timeout = AppLockTimeout(rawValue: rawValue)
            {
                return maybeFixAutoFillBiometricIDLoop(timeout)
            }

            return maybeFixAutoFillBiometricIDLoop(
                ProcessInfo.isRunningOnMac ? .after1minute : .immediately
            )
        }
        set {
            let oldValue = appLockTimeout
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.appLockTimeout.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.appLockTimeout)
            }
        }
    }

    public var isLockAppOnLaunch: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.lockAppOnLaunch) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockAppOnLaunch.rawValue)
                as? Bool
            let defaultValue = ProcessInfo.isRunningOnMac ? true : false
            return stored ?? defaultValue
        }
        set {
            _updateAndNotify(
                oldValue: isLockAppOnLaunch,
                newValue: newValue,
                key: .lockAppOnLaunch)
        }
    }

    public var isLockAppOnScreenLock: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockAppOnScreenLock.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isLockAppOnScreenLock,
                newValue: newValue,
                key: .lockAppOnScreenLock
            )
        }
    }

    public var databaseLockTimeout: DatabaseLockTimeout {
        get {
            if let managedValue = ManagedAppConfig.shared.getIntIfLicensed(.databaseLockTimeout) {
                let nearestTimeout = DatabaseLockTimeout.nearest(forSeconds: managedValue)
                return nearestTimeout
            }

            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.databaseLockTimeout.rawValue) as? Int,
               let timeout = DatabaseLockTimeout(rawValue: rawValue)
            {
                return timeout
            }
            return DatabaseLockTimeout.never
        }
        set {
            let oldValue = databaseLockTimeout
            UserDefaults.appGroupShared.set(
                newValue.rawValue,
                forKey: Keys.databaseLockTimeout.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.databaseLockTimeout)
            }
        }
    }

    public var isLockDatabasesOnTimeout: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.lockDatabasesOnTimeout) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockDatabasesOnTimeout.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isLockDatabasesOnTimeout,
                newValue: newValue,
                key: .lockDatabasesOnTimeout)
        }
    }

    public var isLockDatabasesOnReboot: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.lockDatabasesOnReboot) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockDatabasesOnReboot.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isLockDatabasesOnReboot,
                newValue: newValue,
                key: .lockDatabasesOnReboot)
        }
    }

    public var isLockDatabasesOnScreenLock: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.lockDatabasesOnScreenLock.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isLockDatabasesOnScreenLock,
                newValue: newValue,
                key: .lockDatabasesOnScreenLock
            )
        }
    }

    public var passcodeAttemptsBeforeAppReset: PasscodeAttemptsBeforeAppReset {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.passcodeAttemptsBeforeAppReset.rawValue) as? Int,
               let value = PasscodeAttemptsBeforeAppReset(rawValue: rawValue)
            {
                return value
            }
            return .never
        }
        set {
            let oldValue = passcodeAttemptsBeforeAppReset
            UserDefaults.appGroupShared.set(
                newValue.rawValue,
                forKey: Keys.passcodeAttemptsBeforeAppReset.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.passcodeAttemptsBeforeAppReset)
            }
        }
    }
}
