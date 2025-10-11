//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

internal extension UserDefaults {
    func set(_ value: Any?, forKey key: Settings.Keys) {
        set(value, forKey: key.rawValue)
    }
    func object(forKey key: Settings.Keys) -> Any? {
        return object(forKey: key.rawValue)
    }
    func data(forKey key: Settings.Keys) -> Data? {
        return data(forKey: key.rawValue)
    }
}
