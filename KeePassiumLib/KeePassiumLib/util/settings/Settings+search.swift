//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public var isStartWithSearch: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.startWithSearch.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isStartWithSearch,
                newValue: newValue,
                key: .startWithSearch)
        }
    }

    public var isSearchFieldNames: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.searchFieldNames.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isSearchFieldNames,
                newValue: newValue,
                key: .searchFieldNames)
        }
    }

    public var isSearchProtectedValues: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.searchProtectedValues.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isSearchProtectedValues,
                newValue: newValue,
                key: .searchProtectedValues)
        }
    }

    public var isSearchPasswords: Bool {
        get {
            guard isSearchProtectedValues else {
                return false
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.searchPasswords.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isSearchPasswords,
                newValue: newValue,
                key: .searchPasswords)
        }
    }

}
