//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {
    public enum ClipboardTimeout: Int, CaseIterable {
        public static let visibleValues = [
            after10seconds, after20seconds, after30seconds, after1minute, after90seconds, after2minutes,
            after3minutes, after5minutes, after10minutes, after20minutes, never]
        case never = -1
        case immediately = 0
        case after10seconds = 10
        case after20seconds = 20
        case after30seconds = 30
        case after1minute = 60
        case after90seconds = 90
        case after2minutes = 120
        case after3minutes = 180
        case after5minutes = 300
        case after10minutes = 600
        case after20minutes = 1200

        public var seconds: Int {
            return self.rawValue
        }

        static func nearest(forSeconds seconds: Int) -> ClipboardTimeout {
            let result = Self.allCases.min(by: { item1, item2 in
                return abs(item1.seconds - seconds) < abs(item2.seconds - seconds)
            })
            return result!
        }

    }

    public var clipboardTimeout: ClipboardTimeout {
        get {
            if let managedValue = ManagedAppConfig.shared.getIntIfLicensed(.clipboardTimeout) {
                let nearestTimeout = ClipboardTimeout.nearest(forSeconds: managedValue)
                return nearestTimeout
            }

            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.clipboardTimeout.rawValue) as? Int,
               let timeout = ClipboardTimeout(rawValue: rawValue)
            {
                return timeout
            }
            return ClipboardTimeout.after1minute
        }
        set {
            let oldValue = clipboardTimeout
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.clipboardTimeout.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.clipboardTimeout)
            }
        }
    }

    public var isUniversalClipboardEnabled: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.useUniversalClipboard) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.universalClipboardEnabled.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isUniversalClipboardEnabled,
                newValue: newValue,
                key: .universalClipboardEnabled)
        }
    }
}
