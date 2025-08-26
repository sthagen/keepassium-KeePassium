//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

public protocol SettingsObserver: AnyObject {
    func settingsDidChange(key: Settings.Keys)
}

public class SettingsNotifications {
    public weak var observer: SettingsObserver?

    public init(observer: SettingsObserver? = nil) {
        self.observer = observer
    }

    public func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange(_:)),
            name: Settings.Notifications.settingsChanged,
            object: nil)
    }

    public func stopObserving() {
        NotificationCenter.default.removeObserver(
            self,
            name: Settings.Notifications.settingsChanged,
            object: nil)
    }

    @objc private func settingsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyString = userInfo[Settings.Notifications.userInfoKey] as? String
        else { return }

        guard let key = Settings.Keys(rawValue: keyString) else {
            assertionFailure("Unknown Settings.Keys value: \(keyString)")
            return
        }
        observer?.settingsDidChange(key: key)
    }
}
