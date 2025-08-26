//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public var isHapticFeedbackEnabled: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.hapticFeedbackEnabled.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isHapticFeedbackEnabled,
                newValue: newValue,
                key: .hapticFeedbackEnabled)
        }
    }

    public var isHideAppLockSetupReminder: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.isHideAppProtectionReminder {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.hideAppLockSetupReminder.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isHideAppLockSetupReminder,
                newValue: newValue,
                key: .hideAppLockSetupReminder)
        }
    }

    public static let textScaleAllowedRange: ClosedRange<CGFloat> = 0.5...2.0

    public var textScale: CGFloat {
        get {
            let storedValueOrNil = UserDefaults.appGroupShared
                .object(forKey: Keys.textScale.rawValue)
                as? CGFloat
            if let value = storedValueOrNil {
                return value.clamped(to: Self.textScaleAllowedRange)
            } else {
                return 1.0
            }
        }
        set {
            _updateAndNotify(
                oldValue: textScale,
                newValue: newValue.clamped(to: Self.textScaleAllowedRange),
                key: .textScale)
        }
    }

    public var entryTextFontDescriptor: UIFontDescriptor? {
        get {
            guard let data = UserDefaults.appGroupShared.data(forKey: .entryTextFontDescriptor) else {
                return nil
            }
            return UIFontDescriptor.deserialize(data)
        }
        set {
            let newData = newValue?.serialize()
            let oldData = UserDefaults.appGroupShared.data(forKey: .entryTextFontDescriptor)
            if newData != oldData {
                UserDefaults.appGroupShared.set(newData, forKey: .entryTextFontDescriptor)
                _postChangeNotification(changedKey: .entryTextFontDescriptor)
            }
        }
    }

    public var fieldMenuMode: FieldMenuMode {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.fieldMenuMode.rawValue) as? Int,
               let storedMode = FieldMenuMode(rawValue: rawValue)
            {
                return storedMode
            }
            return .full
        }
        set {
            _updateAndNotify(
                oldValue: fieldMenuMode.rawValue,
                newValue: newValue.rawValue,
                key: .fieldMenuMode)
        }
    }

    public var primaryPaneWidthFraction: CGFloat {
        get {
            let storedValue = UserDefaults.appGroupShared
                .object(forKey: Keys.primaryPaneWidthFraction.rawValue) as? CGFloat
            return storedValue ?? UISplitViewController.automaticDimension
        }
        set {
            _updateAndNotify(
                oldValue: primaryPaneWidthFraction,
                newValue: newValue,
                key: .primaryPaneWidthFraction)
        }
    }
}

extension Settings {

    public enum PasscodeKeyboardType: Int {
        public static let allValues = [numeric, alphanumeric]
        case numeric
        case alphanumeric
        public var title: String {
            switch self {
            case .numeric:
                return NSLocalizedString(
                    "[AppLock/Passcode/KeyboardType/title] Numeric",
                    bundle: Bundle.framework,
                    value: "Numeric",
                    comment: "Type of keyboard to show for App Lock passcode: digits only (PIN code).")
            case .alphanumeric:
                return NSLocalizedString(
                    "[AppLock/Passcode/KeyboardType/title] Alphanumeric",
                    bundle: Bundle.framework,
                    value: "Alphanumeric",
                    comment: "Type of keyboard to show for App Lock passcode: letters and digits.")
            }
        }
    }

    public var passcodeKeyboardType: PasscodeKeyboardType {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.passcodeKeyboardType.rawValue) as? Int,
               let keyboardType = PasscodeKeyboardType(rawValue: rawValue)
            {
                return keyboardType
            }
            return PasscodeKeyboardType.numeric
        }
        set {
            let oldValue = passcodeKeyboardType
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.passcodeKeyboardType.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.passcodeKeyboardType)
            }
        }
    }
}

extension Settings {
    public var passwordGeneratorConfig: PasswordGeneratorParams {
        get {
            let storedData = UserDefaults.appGroupShared
                .object(forKey: Keys.passwordGeneratorConfig.rawValue)
            as? Data
            let storedConfig = PasswordGeneratorParams.deserialize(from: storedData)
            return storedConfig ?? PasswordGeneratorParams()
        }
        set {
            let hasChanged = newValue != passwordGeneratorConfig
            UserDefaults.appGroupShared.set(
                newValue.serialize(),
                forKey: Keys.passwordGeneratorConfig.rawValue
            )
            if hasChanged {
                _postChangeNotification(changedKey: Keys.passwordGeneratorConfig)
            }
        }
    }
}
