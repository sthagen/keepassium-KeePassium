//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

enum DatabaseUpdateCheckStatus: CustomStringConvertible {
    case idle
    case inProgress
    case failed
    case upToDate

    var description: String {
        switch self {
        case .idle:
            return ""
        case .inProgress:
            return LString.statusCheckingDatabaseForExternalChanges
        case .failed:
            return "⚠️ " + LString.statusDatabaseFileUpdateFailed
        case .upToDate:
            return LString.statusDatabaseFileIsUpToDate
        }
    }
}
