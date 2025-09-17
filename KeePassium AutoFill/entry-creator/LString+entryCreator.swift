//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

// swiftlint:disable line_length
extension LString {
    static let titleEntryLocation = NSLocalizedString(
        "[Database/Entry/Location/title]",
        value: "Location",
        comment: "Field title: name of the group that contains the entry"
    )
    static let actionSelectNamedItemTemplate = NSLocalizedString(
        "[Database/Item/SelectNamed/action]",
        value: "Select \"%@\"",
        comment: "Action: select item from a list/menu, with item name in quotes. For example: `Select \"Sample Group\"`"
    )
    static let titleRandomUsernames = NSLocalizedString(
        "[Database/Entry/RandomUsernames/title]",
        value: "Random Usernames",
        comment: "Title of a list with randomly generated usernames"
    )
    static let actionSelectUsername = NSLocalizedString(
        "[Database/Entry/SelectUsername/action]",
        value: "Select Username",
        comment: "Action/button that shows a list of usernames to pick from"
    )
}
// swiftlint:enable line_length
