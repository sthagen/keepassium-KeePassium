//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

public enum DatabaseCloseReason: CustomStringConvertible {
    case userRequest
    case databaseTimeout
    case appLevelOperation

    public var description: String {
        switch self {
        case .userRequest:
            return "User request"
        case .databaseTimeout:
            return "Database timeout"
        case .appLevelOperation:
            return "App-level operation"
        }
    }
}
