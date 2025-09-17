//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

struct EntryCreatorEntryData {
    var parentGroup: Group
    var title: String
    var username: String
    var password: String
    var isPasswordProtected: Bool
    var url: String
    var notes: String
}
