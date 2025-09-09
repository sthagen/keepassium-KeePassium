//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension LString {
    public static let titleNothingSuitableFound = NSLocalizedString(
        "[Search/EmptyResult/title]",
        value: "Nothing suitable found",
        comment: "Placeholder text for empty search results"
    )

    public static let messageHoldKeyForMultiSelection = NSLocalizedString(
        "[Database/Viewer/MultiSelectionKeys/hint]",
        value: "Press and hold Cmd or Shift key to select multiple items.",
        comment: "Info message for keyboard-assisted selection"
    )
}
