//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public enum ShakeGestureAction: Int {
        case nothing
        case lockApp
        case lockAllDatabases
        case quitApp

        public static func getVisibleValues() -> [Self] {
            var result: [Self] = [.nothing]
            if ManagedAppConfig.shared.isAppProtectionAllowed {
                result.append(.lockApp)
            }
            result.append(.lockAllDatabases)
            result.append(.quitApp)
            return result
        }

        public var shortTitle: String {
            switch self {
            case .nothing:
                return NSLocalizedString(
                    "[Settings/ShakeGestureAction/Nothing/shortTitle]",
                    bundle: Bundle.framework,
                    value: "Do Nothing",
                    comment: "An option in Settings. Will be shown as 'When Shaken: Do Nothing'")
            case .lockApp:
                return NSLocalizedString(
                    "[Settings/ShakeGestureAction/LockApp/shortTitle]",
                    bundle: Bundle.framework,
                    value: "Lock App",
                    comment: "An option in Settings. Will be shown as 'When Shaken: Lock App'")
            case .lockAllDatabases:
                return NSLocalizedString(
                    "[Settings/ShakeGestureAction/LockDatabases/shortTitle]",
                    bundle: Bundle.framework,
                    value: "Lock All Databases",
                    comment: "An option in Settings. Will be shown as 'When Shaken: Lock All Databases'")
            case .quitApp:
                return NSLocalizedString(
                    "[Settings/ShakeGestureAction/QuitApp/shortTitle]",
                    bundle: Bundle.framework,
                    value: "Quit App",
                    comment: "An option in Settings. Will be shown as 'When Shaken: Quit App'")

            }
        }

        public var disabledSubtitle: String? {
            switch self {
            case .lockApp:
                return NSLocalizedString(
                    "[Settings/ShakeGestureAction/LockApp/disabledTitle]",
                    bundle: Bundle.framework,
                    value: "Activate app protection first",
                    comment: "Call to action (explains why a setting is disabled)")
            default:
                return nil
            }
        }
    }

    public var shakeGestureAction: ShakeGestureAction {
        get {
            if let rawValue = UserDefaults.appGroupShared
                   .object(forKey: Keys.shakeGestureAction.rawValue) as? Int,
               let action = ShakeGestureAction(rawValue: rawValue)
            {
                if action == .lockApp && !ManagedAppConfig.shared.isAppProtectionAllowed {
                    return .nothing
                }
                return action
            }
            return ShakeGestureAction.nothing
        }
        set {
            let oldValue = shakeGestureAction
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.shakeGestureAction.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.shakeGestureAction)
            }
        }
    }

    public var isConfirmShakeGestureAction: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.confirmShakeGestureAction.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isConfirmShakeGestureAction,
                newValue: newValue,
                key: .confirmShakeGestureAction)
        }
    }
}
